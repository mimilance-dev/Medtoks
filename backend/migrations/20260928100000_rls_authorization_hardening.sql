alter table public.study_plans
  add column created_by_mentor_user_id uuid
    references public.mentor_profiles (user_id) on delete set null;
create index study_plans_creator_idx on public.study_plans (created_by_mentor_user_id, mentee_user_id)
  where created_by_mentor_user_id is not null and archived_at is null;

create table public.analytics_events (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references public.users (id) on delete set null,
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete cascade,
  exam_id uuid references public.exams (id) on delete set null,
  event_name text not null,
  event_data jsonb not null default '{}'::jsonb
    check (jsonb_typeof(event_data) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index analytics_events_mentee_created_idx
  on public.analytics_events (mentee_user_id, created_at desc);
create index analytics_events_exam_name_created_idx
  on public.analytics_events (exam_id, event_name, created_at desc);
create index analytics_events_actor_created_idx
  on public.analytics_events (actor_user_id, created_at desc)
  where actor_user_id is not null;
create trigger analytics_events_set_updated_at
  before update on public.analytics_events
  for each row execute function public.set_updated_at();
alter table public.analytics_events enable row level security;

create or replace function public.is_authorized_mentor_of(p_mentee_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.mentor_profiles mp
    join public.mentor_mentee_relationships r on r.mentor_user_id = mp.user_id
    where mp.user_id = auth.uid()
      and mp.deleted_at is null
      and mp.profile_status = 'active'
      and r.mentee_user_id = p_mentee_user_id
      and r.status = 'active'
      and r.deleted_at is null
  );
$$;

create or replace function public.can_access_subscription(p_subscription_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.subscriptions s
    where s.id = p_subscription_id
      and s.deleted_at is null
      and (
        s.mentee_user_id = auth.uid()
        or public.is_authorized_mentor_of(s.mentee_user_id)
      )
  );
$$;

create or replace function public.can_access_conversation(p_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.conversations c
    where c.id = p_conversation_id
      and c.archived_at is null
      and (
        exists (
          select 1
          from public.conversation_members cm
          where cm.conversation_id = c.id
            and cm.user_id = auth.uid()
            and cm.left_at is null
        )
        or exists (
          select 1
          from public.mentor_mentee_relationships r
          where r.id = c.relationship_id
            and r.status = 'active'
            and r.deleted_at is null
            and public.is_authorized_mentor_of(r.mentee_user_id)
        )
        or exists (
          select 1
          from public.conversation_members cm
          join public.mentor_mentee_relationships r
            on r.mentee_user_id = cm.user_id
          where cm.conversation_id = c.id
            and cm.left_at is null
            and r.status = 'active'
            and r.deleted_at is null
            and public.is_authorized_mentor_of(r.mentee_user_id)
        )
      )
  );
$$;

create or replace function public.can_access_study_plan(p_study_plan_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.study_plans sp
    where sp.id = p_study_plan_id
      and sp.archived_at is null
      and (
        sp.mentee_user_id = auth.uid()
        or (
          sp.created_by_mentor_user_id = auth.uid()
          and public.is_authorized_mentor_of(sp.mentee_user_id)
        )
      )
  );
$$;

revoke all on function public.is_authorized_mentor_of(uuid) from public;
revoke all on function public.can_access_subscription(uuid) from public;
revoke all on function public.can_access_conversation(uuid) from public;
revoke all on function public.can_access_study_plan(uuid) from public;
grant execute on function public.is_authorized_mentor_of(uuid) to authenticated, service_role;
grant execute on function public.can_access_subscription(uuid) to authenticated, service_role;
grant execute on function public.can_access_conversation(uuid) to authenticated, service_role;
grant execute on function public.can_access_study_plan(uuid) to authenticated, service_role;

do $$
begin
  if pg_catalog.to_regclass('storage.objects') is not null
     and pg_catalog.to_regclass('storage.buckets') is not null then
    execute $sql$
      insert into storage.buckets (id, name, public)
      values
        ('medtoks-content', 'medtoks-content', false),
        ('medtoks-message-attachments', 'medtoks-message-attachments', false)
      on conflict (id) do update set public = false
    $sql$;
    execute 'grant usage on schema storage to authenticated, service_role';
    execute 'grant select, insert on storage.objects to authenticated';
    execute 'drop policy if exists medtoks_content_object_read on storage.objects';
    execute $sql$
      create policy medtoks_content_object_read on storage.objects
        for select to authenticated
        using (
          bucket_id = 'medtoks-content'
          and exists (
            select 1 from public.content c
            where c.storage_path = name
              and c.archived_at is null
              and (
                c.author_mentor_user_id = auth.uid()
                or (
                  c.status = 'published'
                  and (
                    c.required_entitlement_code is null
                    or public.has_active_entitlement(c.required_entitlement_code, c.exam_id)
                    or public.can_access_content(c.id)
                  )
                )
              )
          )
        )
    $sql$;
    execute 'drop policy if exists medtoks_message_attachment_object_read on storage.objects';
    execute $sql$
      create policy medtoks_message_attachment_object_read on storage.objects
        for select to authenticated
        using (
          bucket_id = 'medtoks-message-attachments'
          and exists (
            select 1
            from public.message_attachments ma
            join public.messages m on m.id = ma.message_id
            where ma.storage_path = name
              and ma.deleted_at is null
              and m.deleted_at is null
              and public.can_access_conversation(m.conversation_id)
          )
        )
    $sql$;
    execute 'drop policy if exists medtoks_message_attachment_object_insert on storage.objects';
    execute $sql$
      create policy medtoks_message_attachment_object_insert on storage.objects
        for insert to authenticated
        with check (
          bucket_id = 'medtoks-message-attachments'
          and (storage.foldername(name))[1] = (auth.uid())::text
        )
    $sql$;
  end if;
end;
$$;

-- Remove the initial broad or incomplete policies before installing scoped policies.
drop policy if exists users_read_self on public.users;
drop policy if exists mentor_profiles_read on public.mentor_profiles;
drop policy if exists mentee_profiles_read_self on public.mentee_profiles;
drop policy if exists mentee_exam_enrollments_read_self on public.mentee_exam_enrollments;
drop policy if exists subscriptions_read_self on public.subscriptions;
drop policy if exists subscription_entitlements_read_self on public.subscription_entitlements;
drop policy if exists payments_read_self on public.payments;
drop policy if exists relationships_read_participant on public.mentor_mentee_relationships;
drop policy if exists content_read_accessible on public.content;
drop policy if exists content_access_read_self on public.content_access;
drop policy if exists study_plans_read_self on public.study_plans;
drop policy if exists study_plan_tasks_read_owner on public.study_plan_tasks;
drop policy if exists task_completions_read_self on public.task_completions;
drop policy if exists conversations_read_member on public.conversations;
drop policy if exists conversation_members_read_self on public.conversation_members;
drop policy if exists messages_read_member on public.messages;
drop policy if exists message_attachments_read_member on public.message_attachments;
drop policy if exists notifications_read_self on public.notifications;
drop policy if exists notification_preferences_self on public.notification_preferences;

create policy users_read_own_or_authorized_mentee on public.users
  for select to authenticated
  using (
    id = auth.uid() and deleted_at is null
    or (deleted_at is null and public.is_authorized_mentor_of(id))
  );
create policy mentor_profiles_read_self on public.mentor_profiles
  for select to authenticated
  using (user_id = auth.uid() and deleted_at is null);
create policy mentee_profiles_read_own_or_authorized on public.mentee_profiles
  for select to authenticated
  using (
    deleted_at is null
    and (user_id = auth.uid() or public.is_authorized_mentor_of(user_id))
  );
create policy users_update_self on public.users
  for update to authenticated
  using (id = auth.uid() and deleted_at is null)
  with check (id = auth.uid() and deleted_at is null);
create policy mentor_profiles_update_self on public.mentor_profiles
  for update to authenticated
  using (user_id = auth.uid() and deleted_at is null)
  with check (user_id = auth.uid() and deleted_at is null);
create policy mentee_profiles_update_self on public.mentee_profiles
  for update to authenticated
  using (user_id = auth.uid() and deleted_at is null)
  with check (user_id = auth.uid() and deleted_at is null);

create policy mentee_exam_enrollments_read_scoped on public.mentee_exam_enrollments
  for select to authenticated
  using (
    deleted_at is null
    and (mentee_user_id = auth.uid() or public.is_authorized_mentor_of(mentee_user_id))
  );
create policy subscriptions_read_scoped on public.subscriptions
  for select to authenticated
  using (deleted_at is null and public.can_access_subscription(id));
create policy subscription_entitlements_read_scoped on public.subscription_entitlements
  for select to authenticated
  using (public.can_access_subscription(subscription_id));
create policy payments_read_scoped on public.payments
  for select to authenticated
  using (public.can_access_subscription(subscription_id));
create policy relationships_read_participants on public.mentor_mentee_relationships
  for select to authenticated
  using (
    deleted_at is null
    and (mentor_user_id = auth.uid() or mentee_user_id = auth.uid())
  );

create policy content_read_entitled_or_owned on public.content
  for select to authenticated
  using (
    archived_at is null
    and (
      (
        status = 'published'
        and (
          required_entitlement_code is null
          or public.has_active_entitlement(required_entitlement_code, exam_id)
          or public.can_access_content(id)
        )
      )
      or author_mentor_user_id = auth.uid()
    )
  );
create policy content_insert_by_owner on public.content
  for insert to authenticated
  with check (
    author_mentor_user_id = auth.uid()
    and exists (
      select 1 from public.mentor_profiles mp
      where mp.user_id = auth.uid()
        and mp.profile_status = 'active'
        and mp.deleted_at is null
    )
  );
create policy content_update_by_owner on public.content
  for update to authenticated
  using (author_mentor_user_id = auth.uid() and archived_at is null)
  with check (author_mentor_user_id = auth.uid());
create policy content_access_read_scoped on public.content_access
  for select to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.content c
      where c.id = content_id and c.author_mentor_user_id = auth.uid()
    )
  );

create policy study_plans_read_scoped on public.study_plans
  for select to authenticated
  using (public.can_access_study_plan(id));
create policy study_plans_insert_self on public.study_plans
  for insert to authenticated
  with check (mentee_user_id = auth.uid() and created_by_mentor_user_id is null);
create policy study_plans_insert_by_mentor on public.study_plans
  for insert to authenticated
  with check (
    created_by_mentor_user_id = auth.uid()
    and public.is_authorized_mentor_of(mentee_user_id)
  );
create policy study_plans_update_self on public.study_plans
  for update to authenticated
  using (mentee_user_id = auth.uid() and created_by_mentor_user_id is null and archived_at is null)
  with check (mentee_user_id = auth.uid() and created_by_mentor_user_id is null);
create policy study_plans_update_by_creator on public.study_plans
  for update to authenticated
  using (
    created_by_mentor_user_id = auth.uid()
    and public.is_authorized_mentor_of(mentee_user_id)
    and archived_at is null
  )
  with check (
    created_by_mentor_user_id = auth.uid()
    and public.is_authorized_mentor_of(mentee_user_id)
  );
create policy study_plan_tasks_read_scoped on public.study_plan_tasks
  for select to authenticated
  using (deleted_at is null and public.can_access_study_plan(study_plan_id));
create policy study_plan_tasks_insert_scoped on public.study_plan_tasks
  for insert to authenticated
  with check (public.can_access_study_plan(study_plan_id));
create policy study_plan_tasks_update_scoped on public.study_plan_tasks
  for update to authenticated
  using (deleted_at is null and public.can_access_study_plan(study_plan_id))
  with check (public.can_access_study_plan(study_plan_id));
create policy task_completions_read_self on public.task_completions
  for select to authenticated
  using (mentee_user_id = auth.uid());
create policy task_completions_insert_self on public.task_completions
  for insert to authenticated
  with check (
    mentee_user_id = auth.uid()
    and exists (
      select 1
      from public.study_plan_tasks t
      join public.study_plans sp on sp.id = t.study_plan_id
      where t.id = task_id and sp.mentee_user_id = auth.uid()
    )
  );

create policy conversations_read_scoped on public.conversations
  for select to authenticated
  using (public.can_access_conversation(id));
create policy conversation_members_read_scoped on public.conversation_members
  for select to authenticated
  using (user_id = auth.uid() or public.can_access_conversation(conversation_id));
create policy messages_read_scoped on public.messages
  for select to authenticated
  using (deleted_at is null and public.can_access_conversation(conversation_id));
create policy messages_insert_as_member on public.messages
  for insert to authenticated
  with check (
    sender_user_id = auth.uid()
    and public.can_access_conversation(conversation_id)
    and exists (
      select 1 from public.conversation_members cm
      where cm.conversation_id = messages.conversation_id
        and cm.user_id = auth.uid()
        and cm.left_at is null
    )
  );
create policy message_attachments_read_scoped on public.message_attachments
  for select to authenticated
  using (
    deleted_at is null
    and exists (
      select 1 from public.messages m
      where m.id = message_id
        and m.deleted_at is null
        and public.can_access_conversation(m.conversation_id)
    )
  );
create policy message_attachments_insert_own_message on public.message_attachments
  for insert to authenticated
  with check (
    exists (
      select 1 from public.messages m
      where m.id = message_id
        and m.sender_user_id = auth.uid()
        and m.deleted_at is null
        and public.can_access_conversation(m.conversation_id)
    )
  );

create policy notifications_read_self on public.notifications
  for select to authenticated
  using (user_id = auth.uid() and deleted_at is null);
create policy notifications_update_self on public.notifications
  for update to authenticated
  using (user_id = auth.uid() and deleted_at is null)
  with check (user_id = auth.uid() and deleted_at is null);
create policy notification_preferences_self on public.notification_preferences
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
create policy test_attempts_read_self on public.test_attempts
  for select to authenticated
  using (mentee_user_id = auth.uid());
create policy analytics_events_read_scoped on public.analytics_events
  for select to authenticated
  using (
    mentee_user_id = auth.uid()
    or public.is_authorized_mentor_of(mentee_user_id)
  );

revoke all on schema public from anon;
grant usage on schema public to authenticated, service_role;
revoke all on all tables in schema public from anon, authenticated;
grant select on
  public.users, public.mentor_profiles, public.mentee_profiles,
  public.exams, public.subjects, public.topics, public.mentee_exam_enrollments,
  public.subscription_plans, public.plan_entitlements, public.subscriptions,
  public.subscription_entitlements, public.payments, public.mentor_mentee_relationships,
  public.content, public.content_access, public.study_plans, public.study_plan_tasks,
  public.task_completions, public.test_attempts, public.conversations,
  public.conversation_members, public.messages, public.message_attachments,
  public.notifications, public.notification_preferences, public.announcements,
  public.analytics_events
to authenticated;
grant update (display_name, avatar_url, phone_number) on public.users to authenticated;
grant update (professional_title, biography, organization) on public.mentor_profiles to authenticated;
grant update (institution, graduation_year) on public.mentee_profiles to authenticated;
grant insert on public.content to authenticated;
grant update on public.content to authenticated;
grant insert on public.study_plans to authenticated;
grant update (title, description, starts_on, ends_on, status, archived_at)
  on public.study_plans to authenticated;
grant insert on public.study_plan_tasks to authenticated;
grant update (title, description, due_at, sort_order, status, deleted_at)
  on public.study_plan_tasks to authenticated;
grant insert on public.task_completions to authenticated;
grant insert (conversation_id, sender_user_id, body, message_type)
  on public.messages to authenticated;
grant insert on public.message_attachments to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant insert, update, delete on public.notification_preferences to authenticated;
grant all on public.analytics_events to service_role;
