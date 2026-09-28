create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = pg_catalog.now();
  return new;
end;
$$;

create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  phone_number text,
  display_name text not null,
  avatar_url text,
  role text not null default 'mentee'
    check (role in ('mentee', 'mentor', 'admin', 'staff')),
  account_status text not null default 'active'
    check (account_status in ('active', 'suspended', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (email is null or email = btrim(email)),
  check (phone_number is null or phone_number = btrim(phone_number))
);
create unique index users_email_lower_unique on public.users (lower(email)) where email is not null and deleted_at is null;
create index users_role_status_idx on public.users (role, account_status) where deleted_at is null;

create table public.mentor_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users (id) on delete cascade,
  professional_title text,
  biography text,
  organization text,
  is_master_mentor boolean not null default false,
  profile_status text not null default 'active'
    check (profile_status in ('active', 'inactive', 'pending')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create unique index mentor_profiles_single_master_idx on public.mentor_profiles (is_master_mentor)
  where is_master_mentor and deleted_at is null;
create index mentor_profiles_status_idx on public.mentor_profiles (profile_status) where deleted_at is null;

create table public.mentee_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users (id) on delete cascade,
  institution text,
  graduation_year smallint check (graduation_year between 1900 and 2200),
  profile_status text not null default 'active'
    check (profile_status in ('active', 'inactive')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index mentee_profiles_status_idx on public.mentee_profiles (profile_status) where deleted_at is null;

create table public.exams (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code in ('FMGE', 'NEET_PG', 'INICET')),
  name text not null,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);
create index exams_active_idx on public.exams (code) where is_active and archived_at is null;

create table public.subjects (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams (id) on delete restrict,
  code text not null,
  name text not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (exam_id, code),
  unique (id, exam_id)
);
create index subjects_exam_order_idx on public.subjects (exam_id, sort_order) where is_active and archived_at is null;

create table public.topics (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete restrict,
  code text not null,
  name text not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (subject_id, code),
  unique (id, subject_id)
);
create index topics_subject_order_idx on public.topics (subject_id, sort_order) where is_active and archived_at is null;

create table public.mentee_exam_enrollments (
  id uuid primary key default gen_random_uuid(),
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete cascade,
  exam_id uuid not null references public.exams (id) on delete restrict,
  enrolled_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (mentee_user_id, exam_id)
);
create index mentee_exam_enrollments_exam_idx on public.mentee_exam_enrollments (exam_id, mentee_user_id) where deleted_at is null;
