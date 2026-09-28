# Architecture

## Applications

`apps/mentee` and `apps/mentor` are separate Flutter package roots with independent `main.dart`, router, typed app configuration, and Riverpod composition root. Mentee uses a Cupertino application shell for iOS and Android. Mentor uses a responsive Material shell and includes the Flutter web host. Neither application contains feature-domain copies of shared models.

The apps currently depend on shared core configuration, design tokens, networking configuration, and the centralized Supabase initialization boundary. Add domain package dependencies only when an app begins using those contracts.

## Shared Packages

| Package | Owns |
| --- | --- |
| `medtoks_core` | Environment configuration and shared foundations |
| `medtoks_design_system` | Theme and visual tokens; no screens |
| `medtoks_auth` | Identity model and authentication repository contract |
| `medtoks_database` | Supabase configuration and one shared initializer |
| `medtoks_networking` | Shared Dio construction and HTTP defaults |
| `medtoks_subscriptions` | Subscription model and repository contract |
| `medtoks_payments` | Payment result model and provider contract |
| `medtoks_chat` | Message model and repository contract |
| `medtoks_content` | Educational resource model and repository contract |
| `medtoks_notifications` | Notification model and provider contract |
| `medtoks_analytics` | Event model and provider contract |

Package dependencies point inward to shared abstractions; packages never import application code. Each package owns its domain models. There are no cycles, generated files, or provider-specific client implementations in domain packages.

## Composition and State

Riverpod providers in each app expose the app configuration, shared Dio client, and Supabase configuration. Supabase is initialized only at an explicit composition boundary via `medtoks_database`; startup does not require credentials. GoRouter owns the app's root route. Freezed and JSON serialization are intentionally deferred until models need generated serialization behavior.

## Backend Boundary

Supabase is the planned backend. `backend/` contains migration, Edge Function, and seed conventions only. There are no business tables or policies in this foundation. The existing root README is retained as product architecture context, not as evidence that the described entities or integrations are implemented.
