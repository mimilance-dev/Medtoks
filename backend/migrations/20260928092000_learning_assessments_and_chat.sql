create table public.mentor_mentee_relationships (
  id uuid primary key default gen_random_uuid(),
  mentor_user_id uuid not null references public.mentor_profiles (user_id) on delete restrict,
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete restrict,
  status text not null default 'pending'
    check (status in ('pending', 'active', 'paused', 'ended', 'rejected')),
  started_at timestamptz,
  ended_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (mentor_user_id <> mentee_user_id),
  check (ended_at is null or started_at is null or ended_at >= started_at)
);
create unique index mentor_mentee_one_current_relationship_idx
  on public.mentor_mentee_relationships (mentor_user_id, mentee_user_id)
  where status in ('pending', 'active', 'paused') and deleted_at is null;
create index mentor_relationships_mentor_status_idx
  on public.mentor_mentee_relationships (mentor_user_id, status) where deleted_at is null;
create index mentor_relationships_mentee_status_idx
  on public.mentor_mentee_relationships (mentee_user_id, status) where deleted_at is null;

create table public.content (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid references public.exams (id) on delete restrict,
  subject_id uuid,
  topic_id uuid,
  author_mentor_user_id uuid references public.mentor_profiles (user_id) on delete set null,
  content_type text not null
    check (content_type in ('video', 'article', 'document', 'link', 'audio')),
  title text not null,
  description text,
  storage_path text,
  external_url text,
  duration_seconds integer check (duration_seconds is null or duration_seconds >= 0),
  status text not null default 'draft' check (status in ('draft', 'published', 'hidden')),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  check ((storage_path is not null) or (external_url is not null)),
  check (subject_id is null or exam_id is not null),
  check (topic_id is null or subject_id is not null),
  foreign key (subject_id, exam_id) references public.subjects (id, exam_id) on delete restrict,
  foreign key (topic_id, subject_id) references public.topics (id, subject_id) on delete restrict
);
create index content_exam_status_idx on public.content (exam_id, status, created_at desc) where archived_at is null;
create index content_subject_topic_idx on public.content (subject_id, topic_id) where archived_at is null;
create index content_author_idx on public.content (author_mentor_user_id) where archived_at is null;

create table public.content_access (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.content (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  access_source text not null check (access_source in ('subscription', 'relationship', 'manual', 'public')),
  subscription_id uuid references public.subscriptions (id) on delete restrict,
  entitlement_code text check (entitlement_code is null or entitlement_code = lower(entitlement_code)),
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or ends_at > starts_at),
  check ((access_source = 'subscription' and subscription_id is not null and entitlement_code is not null)
      or (access_source <> 'subscription' and subscription_id is null))
);
create unique index content_access_grant_unique_idx
  on public.content_access (content_id, user_id, access_source, coalesce(subscription_id, '00000000-0000-0000-0000-000000000000'::uuid), coalesce(entitlement_code, ''));
create index content_access_user_active_idx on public.content_access (user_id, content_id, ends_at) where revoked_at is null;
create index content_access_subscription_idx on public.content_access (subscription_id) where subscription_id is not null;

create table public.study_plans (
  id uuid primary key default gen_random_uuid(),
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete cascade,
  exam_id uuid not null references public.exams (id) on delete restrict,
  title text not null,
  description text,
  starts_on date,
  ends_on date,
  status text not null default 'active' check (status in ('draft', 'active', 'completed', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  check (ends_on is null or starts_on is null or ends_on >= starts_on)
);
create index study_plans_mentee_status_idx on public.study_plans (mentee_user_id, status) where archived_at is null;
create index study_plans_exam_idx on public.study_plans (exam_id, starts_on) where archived_at is null;

create table public.study_plan_tasks (
  id uuid primary key default gen_random_uuid(),
  study_plan_id uuid not null references public.study_plans (id) on delete cascade,
  topic_id uuid references public.topics (id) on delete set null,
  title text not null,
  description text,
  due_at timestamptz,
  sort_order integer not null default 0 check (sort_order >= 0),
  status text not null default 'pending' check (status in ('pending', 'in_progress', 'completed', 'skipped')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index study_plan_tasks_plan_order_idx on public.study_plan_tasks (study_plan_id, sort_order) where deleted_at is null;
create index study_plan_tasks_due_idx on public.study_plan_tasks (due_at) where status in ('pending', 'in_progress') and deleted_at is null;
create index study_plan_tasks_topic_idx on public.study_plan_tasks (topic_id) where topic_id is not null and deleted_at is null;

create table public.task_completions (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.study_plan_tasks (id) on delete cascade,
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete cascade,
  completed_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (task_id, mentee_user_id)
);
create index task_completions_mentee_completed_idx on public.task_completions (mentee_user_id, completed_at desc);

create table public.tests (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams (id) on delete restrict,
  created_by_mentor_user_id uuid references public.mentor_profiles (user_id) on delete set null,
  title text not null,
  description text,
  time_limit_seconds integer check (time_limit_seconds is null or time_limit_seconds > 0),
  status text not null default 'draft' check (status in ('draft', 'published', 'hidden')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (id, exam_id)
);
create index tests_exam_status_idx on public.tests (exam_id, status, published_at desc) where archived_at is null;
create index tests_author_idx on public.tests (created_by_mentor_user_id)
  where created_by_mentor_user_id is not null and archived_at is null;

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams (id) on delete restrict,
  subject_id uuid not null,
  topic_id uuid,
  created_by_mentor_user_id uuid references public.mentor_profiles (user_id) on delete set null,
  question_type text not null check (question_type in ('single_choice', 'multiple_choice', 'free_text')),
  difficulty text check (difficulty in ('easy', 'medium', 'hard')),
  prompt text not null,
  explanation text,
  status text not null default 'draft' check (status in ('draft', 'published', 'retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (id, exam_id),
  foreign key (subject_id, exam_id) references public.subjects (id, exam_id) on delete restrict,
  foreign key (topic_id, subject_id) references public.topics (id, subject_id) on delete restrict
);
create index questions_exam_subject_status_idx on public.questions (exam_id, subject_id, status) where archived_at is null;
create index questions_topic_idx on public.questions (topic_id) where topic_id is not null and archived_at is null;
create index questions_author_idx on public.questions (created_by_mentor_user_id)
  where created_by_mentor_user_id is not null and archived_at is null;

create table public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions (id) on delete cascade,
  option_text text not null,
  is_correct boolean not null default false,
  sort_order integer not null check (sort_order >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (question_id, sort_order),
  unique (question_id, id)
);
create index question_options_question_idx on public.question_options (question_id, sort_order);

create table public.test_questions (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests (id) on delete cascade,
  exam_id uuid not null,
  question_id uuid not null references public.questions (id) on delete restrict,
  position integer not null check (position > 0),
  marks numeric(8, 2) not null default 1 check (marks >= 0),
  negative_marks numeric(8, 2) not null default 0 check (negative_marks >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (test_id, question_id),
  unique (test_id, position),
  unique (test_id, question_id, id),
  foreign key (test_id, exam_id) references public.tests (id, exam_id) on delete cascade,
  foreign key (question_id, exam_id) references public.questions (id, exam_id) on delete restrict
);
create index test_questions_question_idx on public.test_questions (question_id, test_id);

create table public.test_attempts (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests (id) on delete restrict,
  mentee_user_id uuid not null references public.mentee_profiles (user_id) on delete restrict,
  status text not null default 'in_progress' check (status in ('in_progress', 'submitted', 'timed_out', 'voided')),
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  score numeric(10, 2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, test_id),
  check (submitted_at is null or submitted_at >= started_at)
);
create index test_attempts_mentee_test_idx on public.test_attempts (mentee_user_id, test_id, started_at desc);
create index test_attempts_test_status_idx on public.test_attempts (test_id, status, started_at desc);

create table public.test_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null,
  test_id uuid not null,
  question_id uuid not null,
  free_text_answer text,
  is_correct boolean,
  marks_awarded numeric(8, 2),
  answered_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (attempt_id, test_id) references public.test_attempts (id, test_id) on delete cascade,
  foreign key (test_id, question_id) references public.test_questions (test_id, question_id) on delete restrict,
  unique (attempt_id, question_id),
  unique (id, question_id),
  check (marks_awarded is null or marks_awarded >= 0)
);
create index test_answers_question_idx on public.test_answers (question_id, attempt_id);

create table public.test_answer_options (
  id uuid primary key default gen_random_uuid(),
  test_answer_id uuid not null,
  question_id uuid not null,
  option_id uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (test_answer_id, question_id) references public.test_answers (id, question_id) on delete cascade,
  foreign key (question_id, option_id) references public.question_options (question_id, id) on delete restrict,
  unique (test_answer_id, option_id)
);
create index test_answer_options_question_idx on public.test_answer_options (question_id, option_id);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  conversation_type text not null default 'direct' check (conversation_type in ('direct', 'group', 'support')),
  created_by_user_id uuid references public.users (id) on delete set null,
  relationship_id uuid references public.mentor_mentee_relationships (id) on delete set null,
  title text,
  status text not null default 'active' check (status in ('active', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);
create index conversations_relationship_idx on public.conversations (relationship_id) where relationship_id is not null and archived_at is null;
create index conversations_creator_idx on public.conversations (created_by_user_id)
  where created_by_user_id is not null and archived_at is null;

create table public.conversation_members (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  member_role text not null default 'member' check (member_role in ('member', 'moderator')),
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  last_read_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (conversation_id, user_id),
  unique (conversation_id, user_id, id),
  check (left_at is null or left_at >= joined_at)
);
create index conversation_members_user_idx on public.conversation_members (user_id, conversation_id) where left_at is null;

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null,
  sender_user_id uuid not null,
  body text,
  message_type text not null default 'text' check (message_type in ('text', 'system', 'attachment')),
  edited_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  foreign key (conversation_id, sender_user_id) references public.conversation_members (conversation_id, user_id) on delete restrict,
  check (body is not null or message_type = 'attachment')
);
create index messages_conversation_created_idx on public.messages (conversation_id, created_at desc) where deleted_at is null;
create index messages_sender_idx on public.messages (sender_user_id, created_at desc) where deleted_at is null;

create table public.message_attachments (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages (id) on delete cascade,
  storage_path text not null unique,
  file_name text not null,
  mime_type text not null,
  size_bytes bigint not null check (size_bytes >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index message_attachments_message_idx on public.message_attachments (message_id) where deleted_at is null;
