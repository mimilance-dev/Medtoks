begin;

insert into public.exams (code, name, description, is_active)
values
  ('FMGE', 'Foreign Medical Graduate Examination', 'Development catalog record.', true),
  ('NEET_PG', 'National Eligibility cum Entrance Test - Postgraduate', 'Development catalog record.', true),
  ('INICET', 'Institute of National Importance Combined Entrance Test', 'Development catalog record.', true)
on conflict (code) do update set
  name = excluded.name,
  description = excluded.description,
  is_active = excluded.is_active,
  archived_at = null;

insert into public.subjects (exam_id, code, name, sort_order, is_active)
select e.id, fixture.code, fixture.name, fixture.sort_order, true
from public.exams e
cross join (values
  ('ANATOMY', 'Anatomy', 10),
  ('PHYSIOLOGY', 'Physiology', 20),
  ('BIOCHEMISTRY', 'Biochemistry', 30)
) as fixture(code, name, sort_order)
where e.code in ('FMGE', 'NEET_PG', 'INICET')
on conflict (exam_id, code) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  archived_at = null;

insert into public.topics (subject_id, code, name, sort_order, is_active)
select s.id, 'INTRODUCTION', 'Development sample topic', 10, true
from public.subjects s
join public.exams e on e.id = s.exam_id
where e.code in ('FMGE', 'NEET_PG', 'INICET')
  and s.code in ('ANATOMY', 'PHYSIOLOGY', 'BIOCHEMISTRY')
on conflict (subject_id, code) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  archived_at = null;

insert into public.subscription_plans (
  exam_id, code, name, description, price_minor, currency,
  billing_interval, interval_count, is_active
)
select e.id,
       'dev-full-access',
       'Development full access',
       'Synthetic zero-cost plan for local development only.',
       0,
       'INR',
       'one_time',
       1,
       true
from public.exams e
where e.code in ('FMGE', 'NEET_PG', 'INICET')
on conflict (exam_id, code) do update set
  name = excluded.name,
  description = excluded.description,
  price_minor = excluded.price_minor,
  currency = excluded.currency,
  billing_interval = excluded.billing_interval,
  interval_count = excluded.interval_count,
  is_active = excluded.is_active,
  archived_at = null;

insert into public.plan_entitlements (plan_id, entitlement_code, description, configuration)
select p.id, entitlement.code, entitlement.description, entitlement.configuration
from public.subscription_plans p
join public.exams e on e.id = p.exam_id
cross join (values
  ('content.read', 'Read entitled learning content.', '{"scope":"exam"}'::jsonb),
  ('tests.take', 'Take published practice tests.', '{"scope":"exam"}'::jsonb),
  ('mentor.messaging', 'Use mentor messaging features.', '{"scope":"exam"}'::jsonb)
) as entitlement(code, description, configuration)
where e.code in ('FMGE', 'NEET_PG', 'INICET')
  and p.code = 'dev-full-access'
on conflict (plan_id, entitlement_code) do update set
  description = excluded.description,
  configuration = excluded.configuration;

commit;
