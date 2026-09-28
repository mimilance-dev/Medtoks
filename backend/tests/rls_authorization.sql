\set ON_ERROR_STOP on

begin;

insert into auth.users (id) values
  ('20000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000002'),
  ('20000000-0000-0000-0000-000000000011'),
  ('20000000-0000-0000-0000-000000000012'),
  ('20000000-0000-0000-0000-000000000013');

insert into public.users (id, display_name, role) values
  ('20000000-0000-0000-0000-000000000001', 'RLS Mentor One', 'mentor'),
  ('20000000-0000-0000-0000-000000000002', 'RLS Mentor Two', 'mentor'),
  ('20000000-0000-0000-0000-000000000011', 'RLS Mentee One', 'mentee'),
  ('20000000-0000-0000-0000-000000000012', 'RLS Mentee Two', 'mentee'),
  ('20000000-0000-0000-0000-000000000013', 'RLS Mentee Three', 'mentee');

insert into public.mentor_profiles (user_id, profile_status) values
  ('20000000-0000-0000-0000-000000000001', 'active'),
  ('20000000-0000-0000-0000-000000000002', 'active');
insert into public.mentee_profiles (user_id) values
  ('20000000-0000-0000-0000-000000000011'),
  ('20000000-0000-0000-0000-000000000012'),
  ('20000000-0000-0000-0000-000000000013');

insert into public.mentor_mentee_relationships (mentor_user_id, mentee_user_id, status)
values
  ('20000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000011', 'active'),
  ('20000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000012', 'active');

insert into public.subscriptions (mentee_user_id, exam_id, plan_id, status)
select '20000000-0000-0000-0000-000000000011', e.id, p.id, 'active'
from public.exams e
join public.subscription_plans p on p.exam_id = e.id
where e.code = 'FMGE' and p.code = 'dev-full-access';
insert into public.subscriptions (mentee_user_id, exam_id, plan_id, status)
select '20000000-0000-0000-0000-000000000012', e.id, p.id, 'active'
from public.exams e
join public.subscription_plans p on p.exam_id = e.id
where e.code = 'FMGE' and p.code = 'dev-full-access';

insert into public.payments (
  subscription_id, amount_minor, currency, provider, idempotency_key, status
)
select s.id, 0, 'INR', 'rls-test', 'mentee-' || s.mentee_user_id::text, 'captured'
from public.subscriptions s
where s.mentee_user_id in (
  '20000000-0000-0000-0000-000000000011',
  '20000000-0000-0000-0000-000000000012'
);

insert into public.content (
  exam_id, author_mentor_user_id, content_type, title, storage_path, external_url,
  status, required_entitlement_code
)
select e.id, '20000000-0000-0000-0000-000000000001', 'article', 'RLS entitled FMGE content',
       'fmge/lecture.pdf', 'https://example.test/fmge', 'published', 'content.read'
from public.exams e where e.code = 'FMGE';
insert into public.content (
  exam_id, author_mentor_user_id, content_type, title, storage_path, external_url,
  status, required_entitlement_code
)
select e.id, '20000000-0000-0000-0000-000000000002', 'article', 'RLS unentitled INICET content',
       'inicet/lecture.pdf', 'https://example.test/inicet', 'published', 'content.read'
from public.exams e where e.code = 'INICET';
insert into public.content (
  exam_id, author_mentor_user_id, content_type, title, external_url, status
)
select e.id, '20000000-0000-0000-0000-000000000001', 'article', 'RLS mentor draft',
       'https://example.test/draft', 'draft'
from public.exams e where e.code = 'FMGE';

insert into public.conversations (id, relationship_id, created_by_user_id, status)
select '20000000-0000-0000-0000-000000000101', r.id, r.mentor_user_id, 'active'
from public.mentor_mentee_relationships r
where r.mentor_user_id = '20000000-0000-0000-0000-000000000001';
insert into public.conversations (id, relationship_id, created_by_user_id, status)
select '20000000-0000-0000-0000-000000000102', r.id, r.mentor_user_id, 'active'
from public.mentor_mentee_relationships r
where r.mentor_user_id = '20000000-0000-0000-0000-000000000002';
insert into public.conversations (id, status)
values ('20000000-0000-0000-0000-000000000103', 'active');
insert into public.conversation_members (conversation_id, user_id) values
  ('20000000-0000-0000-0000-000000000101', '20000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000101', '20000000-0000-0000-0000-000000000011'),
  ('20000000-0000-0000-0000-000000000102', '20000000-0000-0000-0000-000000000002'),
  ('20000000-0000-0000-0000-000000000102', '20000000-0000-0000-0000-000000000012'),
  ('20000000-0000-0000-0000-000000000103', '20000000-0000-0000-0000-000000000011');
insert into public.messages (id, conversation_id, sender_user_id, body) values
  ('20000000-0000-0000-0000-000000000201', '20000000-0000-0000-0000-000000000101', '20000000-0000-0000-0000-000000000011', 'Mentee one message'),
  ('20000000-0000-0000-0000-000000000202', '20000000-0000-0000-0000-000000000102', '20000000-0000-0000-0000-000000000012', 'Mentee two message'),
  ('20000000-0000-0000-0000-000000000203', '20000000-0000-0000-0000-000000000103', '20000000-0000-0000-0000-000000000011', 'Mentee one private message');
insert into public.message_attachments (
  message_id, storage_path, file_name, mime_type, size_bytes
)
values
  ('20000000-0000-0000-0000-000000000201', '20000000-0000-0000-0000-000000000011/attachment.pdf', 'attachment.pdf', 'application/pdf', 10),
  ('20000000-0000-0000-0000-000000000202', '20000000-0000-0000-0000-000000000012/attachment.pdf', 'attachment.pdf', 'application/pdf', 10);

do $$
begin
  if pg_catalog.to_regclass('storage.objects') is not null then
    execute $sql$
      insert into storage.objects (bucket_id, name)
      values
        ('medtoks-content', 'fmge/lecture.pdf'),
        ('medtoks-content', 'inicet/lecture.pdf'),
        ('medtoks-message-attachments', '20000000-0000-0000-0000-000000000011/attachment.pdf'),
        ('medtoks-message-attachments', '20000000-0000-0000-0000-000000000012/attachment.pdf')
    $sql$;
  end if;
end;
$$;

insert into public.study_plans (
  id, mentee_user_id, exam_id, created_by_mentor_user_id, title
)
select '20000000-0000-0000-0000-000000000301',
       '20000000-0000-0000-0000-000000000011', e.id, null, 'Mentee one self plan'
from public.exams e where e.code = 'FMGE';
insert into public.study_plans (
  id, mentee_user_id, exam_id, created_by_mentor_user_id, title
)
select '20000000-0000-0000-0000-000000000302',
       '20000000-0000-0000-0000-000000000011', e.id,
       '20000000-0000-0000-0000-000000000001', 'Mentor one plan'
from public.exams e where e.code = 'FMGE';
insert into public.study_plans (
  id, mentee_user_id, exam_id, created_by_mentor_user_id, title
)
select '20000000-0000-0000-0000-000000000303',
       '20000000-0000-0000-0000-000000000012', e.id,
       '20000000-0000-0000-0000-000000000002', 'Mentor two plan'
from public.exams e where e.code = 'FMGE';
insert into public.study_plan_tasks (id, study_plan_id, title) values
  ('20000000-0000-0000-0000-000000000311', '20000000-0000-0000-0000-000000000301', 'Mentee one task'),
  ('20000000-0000-0000-0000-000000000312', '20000000-0000-0000-0000-000000000302', 'Mentor one task'),
  ('20000000-0000-0000-0000-000000000313', '20000000-0000-0000-0000-000000000303', 'Mentor two task');

insert into public.tests (id, exam_id, title, status, published_at)
select '20000000-0000-0000-0000-000000000401', e.id, 'RLS test', 'published', now()
from public.exams e where e.code = 'FMGE';
insert into public.test_attempts (id, test_id, mentee_user_id, status)
values
  ('20000000-0000-0000-0000-000000000411', '20000000-0000-0000-0000-000000000401', '20000000-0000-0000-0000-000000000011', 'submitted'),
  ('20000000-0000-0000-0000-000000000412', '20000000-0000-0000-0000-000000000401', '20000000-0000-0000-0000-000000000012', 'submitted');

insert into public.notifications (id, user_id, notification_type, title) values
  ('20000000-0000-0000-0000-000000000501', '20000000-0000-0000-0000-000000000011', 'test', 'Mentee one notification'),
  ('20000000-0000-0000-0000-000000000502', '20000000-0000-0000-0000-000000000012', 'test', 'Mentee two notification');
insert into public.analytics_events (mentee_user_id, actor_user_id, event_name)
values
  ('20000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000011', 'rls_test'),
  ('20000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000012', 'rls_test');

set local role authenticated;
select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000011', true);
do $$
begin
  if (select count(*) from public.users) <> 1 then raise exception 'mentee can read another user'; end if;
  if (select count(*) from public.mentee_profiles) <> 1 then raise exception 'mentee can read another mentee profile'; end if;
  if (select count(*) from public.subscriptions) <> 1 then raise exception 'mentee can read another subscription'; end if;
  if (select count(*) from public.payments) <> 1 then raise exception 'mentee can read another payment'; end if;
  if (select count(*) from public.content where title = 'RLS entitled FMGE content') <> 1 then raise exception 'active entitlement did not grant content'; end if;
  if (select count(*) from public.content where title = 'RLS unentitled INICET content') <> 0 then raise exception 'content leaked across exam entitlement'; end if;
  if (select count(*) from public.content_access) <> 0 then raise exception 'mentee can read another user content grants'; end if;
  if (select count(*) from public.conversations) <> 2 then raise exception 'mentee conversation scope is incorrect'; end if;
  if (select count(*) from public.messages) <> 2 then raise exception 'mentee message scope is incorrect'; end if;
  if (select count(*) from public.study_plans) <> 2 then raise exception 'mentee study plan scope is incorrect'; end if;
  if (select count(*) from public.study_plan_tasks) <> 2 then raise exception 'mentee task scope is incorrect'; end if;
  if (select count(*) from public.test_attempts) <> 1 then raise exception 'mentee can read another test attempt'; end if;
  if (select count(*) from public.notifications) <> 1 then raise exception 'mentee can read another notification'; end if;
  if (select count(*) from public.analytics_events) <> 1 then raise exception 'mentee can read another analytics event'; end if;
  if has_table_privilege(current_user, 'public.test_answers', 'select') then raise exception 'client can read answer key data'; end if;
  if has_column_privilege(current_user, 'public.users', 'role', 'update') then raise exception 'client can change its role'; end if;
  if pg_catalog.to_regclass('storage.objects') is not null then
    if (select count(*) from storage.objects where bucket_id = 'medtoks-content') <> 1 then raise exception 'storage content entitlement scope is incorrect'; end if;
    if (select count(*) from storage.objects where bucket_id = 'medtoks-message-attachments') <> 1 then raise exception 'storage message attachment scope is incorrect'; end if;
  end if;
end;
$$;

do $$
begin
  if pg_catalog.to_regclass('storage.objects') is not null then
    insert into storage.objects (bucket_id, name)
    values ('medtoks-message-attachments', '20000000-0000-0000-0000-000000000011/new-upload.pdf');
    begin
      insert into storage.objects (bucket_id, name)
      values ('medtoks-message-attachments', '20000000-0000-0000-0000-000000000012/forbidden.pdf');
      raise exception 'user uploaded into another user folder';
    exception when insufficient_privilege then null;
    end;
    begin
      insert into storage.objects (bucket_id, name)
      values ('medtoks-content', 'mentee-upload/forbidden.pdf');
      raise exception 'client uploaded into the content bucket';
    exception when insufficient_privilege then null;
    end;
  end if;
end;
$$;

update public.users set display_name = 'RLS Mentee One Updated'
where id = '20000000-0000-0000-0000-000000000011';
update public.mentee_profiles set institution = 'Synthetic Medical College'
where user_id = '20000000-0000-0000-0000-000000000011';
do $$
begin
  begin
    update public.users set role = 'admin'
    where id = '20000000-0000-0000-0000-000000000011';
    raise exception 'role escalation unexpectedly succeeded';
  exception when insufficient_privilege then null;
  end;
  update public.notifications set read_at = now()
  where id = '20000000-0000-0000-0000-000000000502';
  if found then raise exception 'mentee updated another user notification'; end if;
end;
$$;
insert into public.study_plan_tasks (study_plan_id, title)
values ('20000000-0000-0000-0000-000000000301', 'Mentee-created task');
do $$
begin
  begin
    insert into public.study_plan_tasks (study_plan_id, title)
    values ('20000000-0000-0000-0000-000000000303', 'Cross-tenant task attempt');
    raise exception 'cross-tenant task insert unexpectedly succeeded';
  exception when insufficient_privilege then null;
  end;
end;
$$;

insert into public.messages (conversation_id, sender_user_id, body)
values (
  '20000000-0000-0000-0000-000000000101',
  '20000000-0000-0000-0000-000000000011',
  'Authorized member message'
);
do $$
begin
  begin
    insert into public.messages (conversation_id, sender_user_id, body)
    values (
      '20000000-0000-0000-0000-000000000102',
      '20000000-0000-0000-0000-000000000011',
      'Cross-tenant message attempt'
    );
    raise exception 'cross-tenant message insert unexpectedly succeeded';
  exception
    when insufficient_privilege or foreign_key_violation then null;
  end;
end;
$$;
do $$
begin
  begin
    insert into public.messages (conversation_id, sender_user_id, body)
    values (
      '20000000-0000-0000-0000-000000000103',
      '20000000-0000-0000-0000-000000000001',
      'Mentor without membership'
    );
    raise exception 'mentor sent to a conversation without membership';
  exception
    when insufficient_privilege or foreign_key_violation then null;
  end;
end;
$$;

reset role;
select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000001', true);
set local role authenticated;
do $$
begin
  if (select count(*) from public.mentor_profiles) <> 1 then raise exception 'mentor can read another mentor profile'; end if;
  if (select count(*) from public.mentee_profiles) <> 1 then raise exception 'mentor can read an unauthorized mentee profile'; end if;
  if (select count(*) from public.users where id = '20000000-0000-0000-0000-000000000012') <> 0 then raise exception 'mentor can read an unauthorized mentee identity'; end if;
  if (select count(*) from public.subscriptions) <> 1 then raise exception 'mentor can read an unauthorized subscription'; end if;
  if (select count(*) from public.payments) <> 1 then raise exception 'mentor can read an unauthorized payment'; end if;
  if (select count(*) from public.content where title = 'RLS mentor draft') <> 1 then raise exception 'mentor cannot read owned content'; end if;
  if (select count(*) from public.content where title = 'RLS unentitled INICET content') <> 0 then raise exception 'mentor can read another mentor content'; end if;
  if (select count(*) from public.conversations) <> 2 then raise exception 'mentor conversation scope is incorrect'; end if;
  if (select count(*) from public.messages) <> 3 then raise exception 'mentor message scope is incorrect'; end if;
  if (select count(*) from public.study_plans) <> 1 then raise exception 'mentor can read plans they did not create or are not authorized for'; end if;
  if (select count(*) from public.study_plan_tasks) <> 1 then raise exception 'mentor task scope is incorrect'; end if;
  if (select count(*) from public.analytics_events) <> 1 then raise exception 'mentor analytics scope is incorrect'; end if;
  if pg_catalog.to_regclass('storage.objects') is not null then
    if (select count(*) from storage.objects where bucket_id = 'medtoks-message-attachments') <> 1 then raise exception 'mentor attachment scope is incorrect'; end if;
  end if;
end;
$$;
insert into public.study_plans (
  mentee_user_id, exam_id, created_by_mentor_user_id, title
)
select '20000000-0000-0000-0000-000000000011', e.id,
       '20000000-0000-0000-0000-000000000001', 'Mentor-created in-scope plan'
from public.exams e where e.code = 'FMGE';
do $$
begin
  begin
    insert into public.study_plans (
      mentee_user_id, exam_id, created_by_mentor_user_id, title
    )
    select '20000000-0000-0000-0000-000000000012', e.id,
           '20000000-0000-0000-0000-000000000001', 'Cross-scope mentor plan attempt'
    from public.exams e where e.code = 'FMGE';
    raise exception 'mentor created a plan for an unauthorized mentee';
  exception when insufficient_privilege then null;
  end;
end;
$$;

reset role;
select set_config('request.jwt.claim.sub', '20000000-0000-0000-0000-000000000002', true);
set local role authenticated;
do $$
begin
  if (select count(*) from public.subscriptions) <> 1 then raise exception 'second mentor does not see own authorized subscription'; end if;
  if exists (select 1 from public.subscriptions where mentee_user_id = '20000000-0000-0000-0000-000000000011') then raise exception 'second mentor can read first mentor subscription'; end if;
  if (select count(*) from public.analytics_events) <> 1 then raise exception 'second mentor analytics scope is incorrect'; end if;
end;
$$;

reset role;
rollback;

select 'RLS authorization checks passed' as result;
