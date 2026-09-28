# Environments

Flutter values are compiled into an app with `--dart-define`; `.env.example` is a non-secret reference only and is not loaded automatically. `AppEnvironmentConfig` in `medtoks_core` exposes typed values and validation for `MEDTOKS_ENV`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `API_BASE_URL`, and `FEATURE_MENTOR_DASHBOARD`.

Use the same shape of command for each app, substituting its target:

```sh
cd apps/mentee
flutter run \
  --dart-define=MEDTOKS_ENV=development \
  --dart-define=SUPABASE_URL=https://your-dev-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-dev-publishable-key \
  --dart-define=API_BASE_URL=https://api-dev.example.com \
  --dart-define=FEATURE_MENTOR_DASHBOARD=false
```

For staging or production, set `MEDTOKS_ENV=staging` or `MEDTOKS_ENV=production` and supply that environment's endpoints and publishable key. For the Mentor web app, run the same command from `apps/mentor` with `flutter run -d chrome`; builds accept the same defines, for example `flutter build web --release --dart-define=MEDTOKS_ENV=staging ...`.

Only client-safe Supabase publishable keys may be compiled into Flutter apps. Never provide a service-role key, payment secret, or other privileged credential through a Dart define, source file, CI pull-request secret, or `.env` file. Server credentials belong in the backend deployment's secret store.

Development, staging, and production should use separate Supabase projects, API deployments, credentials, and access policies. Environment labels and feature flags are not security boundaries. Apply and test database RLS and backend authorization independently in every project. Keep local real secrets in ignored files or a secret manager; `.gitignore` excludes `.env*` except `.env.example`.
