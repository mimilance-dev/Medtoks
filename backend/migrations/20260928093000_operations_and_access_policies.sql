alter table public.content
  add column required_entitlement_code text
    check (required_entitlement_code is null or required_entitlement_code = lower(required_entitlement_code));
create index content_required_entitlement_idx
  on public.content (required_entitlement_code, exam_id)
  where required_entitlement_code is not null and archived_at is null;

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  notification_type text not null,
  title text not null,
  body text,
  payload jsonb not null default '{}'::jsonb check (jsonb_typeof(payload) = 'object'),
  scheduled_at timestamptz,
  delivered_at timestamptz,
  read_at timestamptz,
  deduplication_key text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create unique index notifications_user_dedupe_unique_idx
  on public.notifications (user_id, deduplication_key) where deduplication_key is not null;
create index notifications_user_unread_idx
  on public.notifications (user_id, created_at desc) where read_at is null and deleted_at is null;
create index notifications_delivery_idx
  on public.notifications (scheduled_at) where delivered_at is null and deleted_at is null;

create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users (id) on delete cascade,
  email_enabled boolean not null default true,
  push_enabled boolean not null default true,
  in_app_enabled boolean not null default true,
  quiet_hours_start time,
  quiet_hours_end time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((quiet_hours_start is null) = (quiet_hours_end is null))
);
create index notification_preferences_user_idx on public.notification_preferences (user_id);

create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  author_user_id uuid references public.users (id) on delete set null,
  exam_id uuid references public.exams (id) on delete restrict,
  audience text not null default 'all' check (audience in ('all', 'mentors', 'mentees')),
  title text not null,
  body text not null,
  publish_at timestamptz not null default now(),
  expires_at timestamptz,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  check (expires_at is null or expires_at > publish_at)
);
create index announcements_published_idx
  on public.announcements (publish_at desc, expires_at)
  where is_published and archived_at is null;
create index announcements_exam_audience_idx
  on public.announcements (exam_id, audience) where archived_at is null;
create index announcements_author_idx on public.announcements (author_user_id)
  where author_user_id is not null and archived_at is null;

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references public.users (id) on delete set null,
  action text not null,
  entity_table text not null,
  entity_id uuid,
  old_values jsonb check (old_values is null or jsonb_typeof(old_values) = 'object'),
  new_values jsonb check (new_values is null or jsonb_typeof(new_values) = 'object'),
  request_id uuid,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index audit_logs_actor_created_idx on public.audit_logs (actor_user_id, created_at desc);
create index audit_logs_entity_idx on public.audit_logs (entity_table, entity_id, created_at desc);
create index audit_logs_request_idx on public.audit_logs (request_id) where request_id is not null;

create or replace function public.has_active_entitlement(
  p_entitlement_code text,
  p_exam_id uuid default null
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.subscriptions as s
    join public.subscription_entitlements as se on se.subscription_id = s.id
    where s.mentee_user_id = auth.uid()
      and s.status in ('trialing', 'active', 'past_due')
      and s.deleted_at is null
      and (s.starts_at is null or s.starts_at <= pg_catalog.now())
      and (s.ends_at is null or s.ends_at > pg_catalog.now())
      and se.entitlement_code = p_entitlement_code
      and se.revoked_at is null
      and se.starts_at <= pg_catalog.now()
      and (se.ends_at is null or se.ends_at > pg_catalog.now())
      and (p_exam_id is null or s.exam_id = p_exam_id)
  );
$$;

create or replace function public.can_access_content(p_content_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.content_access as ca
    join public.content as c on c.id = ca.content_id
    where ca.content_id = p_content_id
      and ca.user_id = auth.uid()
      and ca.revoked_at is null
      and ca.starts_at <= pg_catalog.now()
      and (ca.ends_at is null or ca.ends_at > pg_catalog.now())
      and (
        ca.access_source <> 'subscription'
        or public.has_active_entitlement(ca.entitlement_code, c.exam_id)
      )
  );
$$;

create or replace function public.copy_plan_entitlements_to_subscription()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.subscription_entitlements (
    subscription_id, entitlement_code, configuration, starts_at, ends_at
  )
  select new.id,
         pe.entitlement_code,
         pe.configuration,
         coalesce(new.starts_at, pg_catalog.now()),
         new.ends_at
  from public.plan_entitlements as pe
  where pe.plan_id = new.plan_id
  on conflict (subscription_id, entitlement_code) do nothing;
  return new;
end;
$$;
create trigger subscriptions_copy_plan_entitlements
  after insert on public.subscriptions
  for each row execute function public.copy_plan_entitlements_to_subscription();

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'users', 'mentor_profiles', 'mentee_profiles', 'exams', 'subjects', 'topics',
    'mentee_exam_enrollments', 'subscription_plans', 'plan_entitlements', 'subscriptions',
    'subscription_entitlements', 'payments', 'mentor_mentee_relationships', 'content',
    'content_access', 'study_plans', 'study_plan_tasks', 'task_completions', 'tests',
    'questions', 'question_options', 'test_questions', 'test_attempts', 'test_answers',
    'test_answer_options', 'conversations', 'conversation_members', 'messages',
    'message_attachments', 'notifications', 'notification_preferences', 'announcements',
    'audit_logs'
  ] loop
    execute pg_catalog.format(
      'create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()',
      table_name
    );
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'users', 'mentor_profiles', 'mentee_profiles', 'exams', 'subjects', 'topics',
    'mentee_exam_enrollments', 'subscription_plans', 'plan_entitlements', 'subscriptions',
    'subscription_entitlements', 'payments', 'mentor_mentee_relationships', 'content',
    'content_access', 'study_plans', 'study_plan_tasks', 'task_completions', 'tests',
    'questions', 'question_options', 'test_questions', 'test_attempts', 'test_answers',
    'test_answer_options', 'conversations', 'conversation_members', 'messages',
    'message_attachments', 'notifications', 'notification_preferences', 'announcements',
    'audit_logs'
  ] loop
    execute pg_catalog.format('alter table public.%I enable row level security', table_name);
  end loop;
end;
$$;

create policy users_read_self on public.users
  for select to authenticated using (id = auth.uid() and deleted_at is null);
create policy mentor_profiles_read on public.mentor_profiles
  for select to authenticated using (deleted_at is null and (user_id = auth.uid() or profile_status = 'active'));
create policy mentee_profiles_read_self on public.mentee_profiles
  for select to authenticated using (user_id = auth.uid() and deleted_at is null);
create policy exams_read_active on public.exams
  for select to authenticated using (is_active and archived_at is null);
create policy subjects_read_active on public.subjects
  for select to authenticated using (is_active and archived_at is null);
create policy topics_read_active on public.topics
  for select to authenticated using (is_active and archived_at is null);
create policy mentee_exam_enrollments_read_self on public.mentee_exam_enrollments
  for select to authenticated using (mentee_user_id = auth.uid() and deleted_at is null);
create policy plans_read_active on public.subscription_plans
  for select to authenticated using (is_active and archived_at is null);
create policy plan_entitlements_read_active on public.plan_entitlements
  for select to authenticated using (exists (
    select 1 from public.subscription_plans p
    where p.id = plan_id and p.is_active and p.archived_at is null
  ));
create policy subscriptions_read_self on public.subscriptions
  for select to authenticated using (mentee_user_id = auth.uid() and deleted_at is null);
create policy subscription_entitlements_read_self on public.subscription_entitlements
  for select to authenticated using (exists (
    select 1 from public.subscriptions s
    where s.id = subscription_id and s.mentee_user_id = auth.uid() and s.deleted_at is null
  ));
create policy payments_read_self on public.payments
  for select to authenticated using (exists (
    select 1 from public.subscriptions s
    where s.id = subscription_id and s.mentee_user_id = auth.uid() and s.deleted_at is null
  ));
create policy relationships_read_participant on public.mentor_mentee_relationships
  for select to authenticated using (mentor_user_id = auth.uid() or mentee_user_id = auth.uid());
create policy content_read_accessible on public.content
  for select to authenticated using (
    archived_at is null and status = 'published' and (
      required_entitlement_code is null
      or has_active_entitlement(required_entitlement_code, exam_id)
      or can_access_content(id)
      or author_mentor_user_id = auth.uid()
    )
  );
create policy content_access_read_self on public.content_access
  for select to authenticated using (user_id = auth.uid());
create policy study_plans_read_self on public.study_plans
  for select to authenticated using (mentee_user_id = auth.uid() and archived_at is null);
create policy study_plan_tasks_read_owner on public.study_plan_tasks
  for select to authenticated using (exists (
    select 1 from public.study_plans p
    where p.id = study_plan_id and p.mentee_user_id = auth.uid() and p.archived_at is null
  ));
create policy task_completions_read_self on public.task_completions
  for select to authenticated using (mentee_user_id = auth.uid());
create policy conversations_read_member on public.conversations
  for select to authenticated using (archived_at is null and exists (
    select 1 from public.conversation_members cm
    where cm.conversation_id = id and cm.user_id = auth.uid() and cm.left_at is null
  ));
create policy conversation_members_read_self on public.conversation_members
  for select to authenticated using (user_id = auth.uid());
create policy messages_read_member on public.messages
  for select to authenticated using (deleted_at is null and exists (
    select 1 from public.conversation_members cm
    where cm.conversation_id = messages.conversation_id and cm.user_id = auth.uid() and cm.left_at is null
  ));
create policy message_attachments_read_member on public.message_attachments
  for select to authenticated using (deleted_at is null and exists (
    select 1 from public.messages m
    join public.conversation_members cm on cm.conversation_id = m.conversation_id
    where m.id = message_id and m.deleted_at is null and cm.user_id = auth.uid() and cm.left_at is null
  ));
create policy notifications_read_self on public.notifications
  for select to authenticated using (user_id = auth.uid() and deleted_at is null);
create policy notification_preferences_self on public.notification_preferences
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy announcements_read_published on public.announcements
  for select to authenticated using (
    is_published and archived_at is null and publish_at <= pg_catalog.now()
    and (expires_at is null or expires_at > pg_catalog.now())
    and (exam_id is null or exists (
      select 1 from public.mentee_exam_enrollments e
      where e.exam_id = announcements.exam_id and e.mentee_user_id = auth.uid() and e.deleted_at is null
    ))
    and (audience = 'all' or exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = case audience when 'mentors' then 'mentor' else 'mentee' end
    ))
  );

revoke all on function public.has_active_entitlement(text, uuid) from public;
revoke all on function public.can_access_content(uuid) from public;
revoke all on function public.copy_plan_entitlements_to_subscription() from public;
grant execute on function public.has_active_entitlement(text, uuid) to authenticated, service_role;
grant execute on function public.can_access_content(uuid) to authenticated, service_role;

revoke all on all tables in schema public from anon, authenticated;
grant select on
  public.users, public.mentor_profiles, public.mentee_profiles, public.exams,
  public.subjects, public.topics, public.mentee_exam_enrollments,
  public.subscription_plans, public.plan_entitlements, public.subscriptions,
  public.subscription_entitlements, public.payments, public.mentor_mentee_relationships,
  public.content, public.content_access, public.study_plans, public.study_plan_tasks,
  public.task_completions, public.conversations, public.conversation_members,
  public.messages, public.message_attachments, public.notifications,
  public.notification_preferences, public.announcements
to authenticated;
grant insert, update, delete on public.notification_preferences to authenticated;
grant all on all tables in schema public to service_role;
