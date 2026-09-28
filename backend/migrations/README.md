# Migrations

Reviewed PostgreSQL migrations live here as `YYYYMMDDHHMMSS_descriptive_name.sql`, in timestamp order. The initial schema is documented in [`docs/database.md`](../../docs/database.md). Keep migrations forward-only; after a migration has been applied to a shared environment, make changes in a new migration rather than editing history.

These files target Supabase PostgreSQL and depend on `auth.users`, `auth.uid()`, and the `authenticated` / `service_role` roles. Apply and verify them against a disposable local Supabase database before deployment. Production deployment remains a deliberate, manually reviewed operation.
