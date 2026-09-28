create table public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams (id) on delete restrict,
  code text not null,
  name text not null,
  description text,
  price_minor bigint not null check (price_minor >= 0),
  currency char(3) not null default 'INR' check (currency = upper(currency)),
  billing_interval text not null check (billing_interval in ('one_time', 'month', 'year')),
  interval_count integer not null default 1 check (interval_count > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (exam_id, code),
  unique (id, exam_id)
);
create index subscription_plans_exam_active_idx on public.subscription_plans (exam_id, is_active) where archived_at is null;

create table public.plan_entitlements (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.subscription_plans (id) on delete cascade,
  entitlement_code text not null check (entitlement_code = lower(entitlement_code)),
  description text,
  configuration jsonb not null default '{}'::jsonb check (jsonb_typeof(configuration) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plan_id, entitlement_code)
);
create index plan_entitlements_code_idx on public.plan_entitlements (entitlement_code, plan_id);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete restrict,
  exam_id uuid not null references public.exams (id) on delete restrict,
  plan_id uuid not null,
  status text not null default 'pending'
    check (status in ('pending', 'trialing', 'active', 'past_due', 'paused', 'cancelled', 'expired')),
  starts_at timestamptz,
  ends_at timestamptz,
  cancel_at_period_end boolean not null default false,
  cancelled_at timestamptz,
  provider text,
  provider_subscription_id text,
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (ends_at is null or starts_at is null or ends_at > starts_at),
  unique (id, mentee_user_id, exam_id),
  foreign key (plan_id, exam_id) references public.subscription_plans (id, exam_id) on delete restrict
);
create unique index subscriptions_one_current_per_mentee_exam_idx
  on public.subscriptions (mentee_user_id, exam_id)
  where status in ('pending', 'trialing', 'active', 'past_due') and deleted_at is null;
create unique index subscriptions_provider_id_unique
  on public.subscriptions (provider, provider_subscription_id)
  where provider is not null and provider_subscription_id is not null;
create index subscriptions_mentee_status_idx on public.subscriptions (mentee_user_id, status, ends_at) where deleted_at is null;
create index subscriptions_exam_status_idx on public.subscriptions (exam_id, status) where deleted_at is null;
create index subscriptions_plan_idx on public.subscriptions (plan_id);

create table public.subscription_entitlements (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references public.subscriptions (id) on delete cascade,
  entitlement_code text not null check (entitlement_code = lower(entitlement_code)),
  configuration jsonb not null default '{}'::jsonb check (jsonb_typeof(configuration) = 'object'),
  starts_at timestamptz not null,
  ends_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or ends_at > starts_at),
  unique (subscription_id, entitlement_code)
);
create index subscription_entitlements_access_idx
  on public.subscription_entitlements (entitlement_code, starts_at, ends_at)
  where revoked_at is null;

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references public.subscriptions (id) on delete restrict,
  amount_minor bigint not null check (amount_minor >= 0),
  currency char(3) not null default 'INR' check (currency = upper(currency)),
  status text not null default 'pending'
    check (status in ('pending', 'authorized', 'captured', 'failed', 'refunded', 'partially_refunded')),
  provider text not null,
  provider_payment_id text,
  provider_order_id text,
  idempotency_key text not null,
  failure_code text,
  failure_message text,
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, idempotency_key)
);
create unique index payments_provider_payment_unique
  on public.payments (provider, provider_payment_id) where provider_payment_id is not null;
create index payments_subscription_created_idx on public.payments (subscription_id, created_at desc);
create index payments_status_created_idx on public.payments (status, created_at desc);
