# Backend

## Prerequisites and Local Setup

Install the Supabase CLI using its official instructions for your operating system. The CLI was unavailable while this repository was scaffolded, so no generated Supabase configuration or CLI output is included. Once installed, initialize/configure the local project with the CLI version selected by the team, then use:

```sh
supabase start
supabase status
supabase db reset
supabase functions serve health
```

Local Supabase requires Docker. Keep local CLI state and credentials out of version control. Configure separate Supabase projects and access policies for development, staging, and production; never reuse a production service-role key locally or in Flutter.

## Migrations and Seeds

Store reviewed SQL migrations in `backend/migrations/` using timestamped names, for example `YYYYMMDDHHMMSS_descriptive_name.sql`. The initial platform schema is documented in [database.md](database.md). These migrations depend on Supabase Auth (`auth.users`, `auth.uid()`) and should be replayed against a disposable local Supabase database before review. Do not edit an already-applied migration; add a new forward migration instead.

Only put synthetic, non-sensitive development fixtures in `backend/seed/`. The idempotent [development seed](../backend/seed/development.sql) includes exam catalog data and zero-cost development plans. Do not seed credentials, real patient/mentee data, or production records. Run it only against a local development database after applying migrations; create test identities through Supabase Auth.

Run the transactional RLS authorization suite against the disposable local database after migrations and seed data are applied:

```sh
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f backend/tests/rls_authorization.sql
```

The suite creates synthetic Auth identities and rolls back its fixtures. Review [security-model.md](security-model.md) before changing grants, RLS policies, or security-definer helpers.

## Edge Functions

`backend/functions/health/index.ts` is a credential-free runtime smoke endpoint. Add business functions only in a later feature task. Keep privileged provider credentials in Supabase function secrets, validate caller authorization server-side, and do not expose secrets in responses or client configuration.

Use the Supabase CLI's documented local migration, function deployment, and secret-management commands for the pinned CLI version. Production deployment remains a deliberate, manually reviewed operation; this repository has no automatic production deployment workflow.
