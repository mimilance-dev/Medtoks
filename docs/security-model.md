# Database Security Model

Authorization is enforced in PostgreSQL with row-level security (RLS) and explicit grants. Flutter visibility is not an authorization boundary. Every authenticated request is scoped from `auth.uid()`; clients cannot submit a trusted actor ID to widen access. `service_role` is reserved for trusted backend code and must never be shipped to an app.

## Identity and Scope

- `users.id` is the Supabase Auth user UUID. Clients can read their own user row and edit only `display_name`, `avatar_url`, and `phone_number`. Role, account status, email identity, and deletion state are server-managed.
- A mentee can read their own mentee profile and edit only `institution` and `graduation_year`. A mentor can read and update only their own mentor profile; they can edit only `professional_title`, `biography`, and `organization`.
- A mentor's authorized mentees are derived from a non-deleted relationship whose status is `active`, plus an active, non-deleted mentor profile. Pending, paused, ended, rejected, or deleted relationships do not grant mentor scope.
- Mentors can read the user/profile rows, subscriptions, subscription entitlements, payments, and analytics events for those authorized mentees. They cannot choose a mentee ID in a query to expand that scope.
- Mentees can read only their own subscription, entitlement rows, payment history, test attempts, notification records, study plans, and tasks. Test answer/correctness tables are not directly granted to authenticated clients; expose assessment delivery and scoring through trusted server code that omits answer keys.

## Resource Policies

| Resource | Mentee | Mentor |
| --- | --- | --- |
| Identity/profile | Own user and mentee profile; safe-column updates only | Own user and mentor profile; safe-column updates only; authorized mentee identity/profile |
| Subscriptions/payments | Own rows | Rows for actively authorized mentees |
| Content | Published free content, active entitlement content, or explicit active content grant | Content authored/owned by the mentor; mentee entitlements do not transfer content ownership |
| Study plans/tasks | Own plans and their tasks; may create plans and tasks for self | Only plans they created for an actively authorized mentee, and the plan tasks |
| Conversations/messages | Conversations where they are an active member | Active member conversations plus conversations involving their actively authorized mentees |
| Message writes | Insert as self only while an active member | Insert as self only while an active member; relationship visibility alone does not grant send permission |
| Test attempts | Own attempts | No direct attempt rows; aggregate analytics is separately scoped |
| Notifications/preferences | Own notifications and preferences | No access to mentee notifications/preferences |
| Analytics events | Rows about self | Rows whose mentee is actively authorized |

A `content.required_entitlement_code` of `NULL` means published content is free for authenticated users. A non-null code requires an active matching entitlement for the content's exam or an explicit unexpired, non-revoked `content_access` grant. Subscription-derived grants also require a qualifying subscription status and valid time window. Treating free content as available is an explicit product rule, not a client-side bypass.

When Supabase Storage is installed, the migration creates private `medtoks-content` and `medtoks-message-attachments` buckets. Object reads are tied back to the corresponding content or message-attachment row and reuse the same entitlement/conversation checks. Authenticated uploads are limited to the uploader's UUID folder in the message-attachment bucket; content uploads remain server-only. Do not make either bucket public or issue long-lived signed URLs.

`study_plans.created_by_mentor_user_id` records mentor authorship. Mentees can create plans for themselves; mentors can create plans only for active mentees and later read/update only plans bearing their own creator ID. `analytics_events` is an append-only-by-client, server-written event table keyed to a mentee; mentors see only events inside their active relationship scope.

## Implementation Controls

- The hardening migration removes the initial broad policies and replaces them with owner-, membership-, entitlement-, or relationship-scoped policies.
- RLS is paired with least-privilege table and column grants. Authenticated users cannot write subscriptions, payments, relationships, entitlements, test answers, announcements, audit logs, or analytics events. They cannot change roles or profile ownership fields.
- Security-definer helpers (`is_authorized_mentor_of`, `can_access_subscription`, `can_access_conversation`, and `can_access_study_plan`) use a fixed empty `search_path`, derive the caller from `auth.uid()`, and are not executable by `PUBLIC`. They centralize scope checks without recursive policy evaluation.
- Conversation membership is necessary to send messages. Mentor relationship scope grants conversation/message visibility for relevant mentees, but is not sufficient to impersonate a conversation member.
- Storage object RLS complements table RLS: content objects require the same entitlement/ownership as their content row, and attachment objects require an accessible attachment row in an accessible conversation.
- Catalog rows and active subscription plans are readable to authenticated users. Assessment question banks and answer keys have no authenticated table grants; serve them through a reviewed backend endpoint.
- Audit logs have RLS enabled and no authenticated grants. Use a privileged server path for audit writes and access.

## Automated Authorization Tests

The SQL suite is [backend/tests/rls_authorization.sql](../backend/tests/rls_authorization.sql). It runs in a transaction and rolls back its synthetic Auth users and product fixtures. Against a disposable local Supabase database, after applying migrations and the development seed, run:

```sh
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f backend/tests/rls_authorization.sql
```

The suite exercises mentee and mentor reads, active-relationship tenant boundaries, entitlement exam scoping, conversation/message visibility, authorized and rejected writes, profile role-escalation prevention, task and study-plan ownership, test attempt ownership, notification privacy, analytics scope, and denial of direct access to answer-key data. Keep these checks in the release gate for policy changes.

## Operational Requirements

- Never use a client-provided user ID as the authorization source. Trusted backend writes must validate the caller and rely on RLS as defense in depth.
- Keep the Supabase service-role key exclusively in Edge Function/server secrets. Never expose it through Flutter configuration.
- Re-run the RLS tests after policy, grant, relationship-status, or entitlement changes. Validate with at least two mentors and multiple mentees so cross-tenant tests are meaningful.
- Treat changes to `SECURITY DEFINER` functions, table grants, and RLS-disabled objects as security-sensitive migrations requiring review.
