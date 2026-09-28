# Development seed data

`development.sql` seeds the FMGE, NEET PG, and INICET catalog, sample subjects/topics, and zero-cost local-only plans with representative entitlements. It is synthetic and safe to rerun after applying the migrations.

Run only against a local development database. It does not create Auth users, passwords, or profile records; create test identities through Supabase Auth and provision their application profiles through trusted backend code. Never run this seed against staging or production.
