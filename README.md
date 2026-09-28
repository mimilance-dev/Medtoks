# Medtoks
# 🩺 Medical Mentorship Platform

## Workspace Foundation

This repository contains two independent Flutter applications and shared Dart packages. The Mentee app targets iOS and Android; the Mentor app targets web and is structured for future Windows and macOS builds. The architecture proposal below is retained as product context. No business features, production database schema, or provider integrations are implemented by this foundation.

### Prerequisites

- Flutter 3.32.8 (includes Dart 3.8.x); use this version for local development and CI.
- Git and a supported Flutter platform toolchain. Android builds require Android Studio/Android SDK; iOS builds require macOS and Xcode.
- Supabase CLI only when working with the local backend.

### Bootstrap

```sh
dart pub global activate melos 7.1.0
melos bootstrap
melos run analyze
melos run test
```

Run individual apps from their directories with `flutter run` (Mentee on an available mobile target, Mentor with `flutter run -d chrome`). Run the Mentor web build with `cd apps/mentor && flutter build web`.

### Development Workflow

1. Install the pinned Flutter SDK and activate Melos.
2. Run `melos bootstrap` after checkout or dependency changes.
3. Run `melos run format`, `melos run analyze`, and `melos run test` before opening a pull request.
4. Add shared contracts and infrastructure to `packages/`; keep app-specific composition and navigation in each app.
5. Follow [local development](docs/development.md), [environment configuration](docs/environments.md), and [backend setup](docs/backend.md).

See [architecture overview](docs/architecture.md) for package boundaries and dependency direction. Cloud development environments can run Dart analysis and web builds, but cannot build iOS/macOS applications without a macOS host. Windows desktop builds likewise require a Windows host.

## Architecture & Technical Documentation

> **A scalable medical education and mentorship platform for FMGE, NEET PG, and INI-CET aspirants.**

This document defines the technical architecture, application structure, backend services, data model, security model, development strategy, and deployment approach for the Medical Mentorship Platform.

---

## 📑 Table of Contents

* [1. System Architecture](#1-system-architecture)
* [2. Application Architecture](#2-application-architecture)
* [3. Backend Architecture](#3-backend-architecture)
* [4. Database Architecture](#4-database-architecture)
* [5. Authentication Architecture](#5-authentication-architecture)
* [6. Authorization Architecture](#6-authorization-architecture)
* [7. Subscription Architecture](#7-subscription-architecture)
* [8. Payment Architecture](#8-payment-architecture)
* [9. Chat Architecture](#9-chat-architecture)
* [10. Notification Architecture](#10-notification-architecture)
* [11. Content Architecture](#11-content-architecture)
* [12. Testing Architecture](#12-testing-architecture)
* [13. CI/CD Architecture](#13-cicd-architecture)
* [14. Security Architecture](#14-security-architecture)
* [15. Repository Architecture](#15-repository-architecture)
* [16. Development Roadmap](#16-development-roadmap)
* [17. Assumptions](#17-assumptions)
* [18. Risks](#18-risks)
* [19. Architectural Decisions](#19-architectural-decisions)
* [20. Decisions Requiring Clarification](#20-decisions-requiring-clarification)

---

# 1. 🏗️ System Architecture

The platform follows a **client → Supabase backend → third-party services** architecture.

### Client Applications

| Application        | Platform              | Purpose                                                            |
| ------------------ | --------------------- | ------------------------------------------------------------------ |
| 📱 **Mentee App**  | iOS + Android         | Learning, mentorship, subscriptions, study plans and progress      |
| 🖥️ **Mentor App** | Web + Windows + macOS | Mentee management, content management, communication and analytics |

### Backend

**Supabase** acts as the primary Backend-as-a-Service platform:

* PostgreSQL database
* Authentication
* Realtime subscriptions
* File storage
* Edge Functions
* Row-Level Security (RLS)

### Third-Party Services

| Service                         | Responsibility              |
| ------------------------------- | --------------------------- |
| 💳 **Razorpay**                 | Payments & subscriptions    |
| 🔔 **Firebase Cloud Messaging** | Push notifications          |
| 📊 **Firebase Analytics**       | Product and usage analytics |

### High-Level Architecture

```text
                    ┌─────────────────────────┐
                    │      Mentee App         │
                    │  Flutter / iOS / Android│
                    └────────────┬────────────┘
                                 │
                                 │
                    ┌────────────▼────────────┐
                    │      Supabase            │
                    │                          │
                    │  ┌────────────────────┐  │
                    │  │ PostgreSQL         │  │
                    │  │ Auth               │  │
                    │  │ Realtime           │  │
                    │  │ Storage            │  │
                    │  │ Edge Functions     │  │
                    │  └────────────────────┘  │
                    └───────┬────────┬────────┘
                            │        │
              ┌─────────────┘        └──────────────┐
              ▼                                      ▼
      ┌───────────────┐                    ┌──────────────────┐
      │   Razorpay    │                    │ Firebase         │
      │   Payments    │                    │ FCM + Analytics  │
      └───────────────┘                    └──────────────────┘
                            ▲
                            │
                    ┌───────┴────────────┐
                    │    Mentor App      │
                    │ Flutter Web/Desktop│
                    └────────────────────┘
```

---

# 2. 📱 Application Architecture

The applications will be built using **Flutter + Dart** with a feature-first Clean Architecture approach.

### Core Technologies

| Layer                | Technology             |
| -------------------- | ---------------------- |
| UI                   | Flutter                |
| Language             | Dart                   |
| State Management     | Riverpod               |
| Navigation           | GoRouter               |
| Models               | Freezed                |
| Networking           | Dio                    |
| Secure Storage       | Flutter Secure Storage |
| Backend SDK          | Supabase Flutter SDK   |
| Architecture         | Clean Architecture     |
| Dependency Injection | Riverpod               |

### Architectural Principles

* **Feature-first organization**
* **Clean Architecture**
* **Repository Pattern**
* **Dependency Injection**
* **Immutable models**
* **Separation of concerns**
* **High testability**
* **Maximum code reuse**

### Application Layers

```text
Presentation
     │
     ▼
Application / State
     │
     ▼
Domain
     │
     ▼
Data
     │
     ▼
Supabase / External APIs
```

### Shared Code

Common functionality will be extracted into reusable packages:

* Models
* API clients
* Repositories
* Authentication
* Subscription logic
* UI components
* Utilities
* Validation

This minimizes duplication between the Mentee and Mentor applications.

---

# 3. ☁️ Backend Architecture

**Supabase** will serve as the primary backend platform.

### Core Services

#### PostgreSQL

Responsible for:

* User data
* Profiles
* Subscriptions
* Payments
* Study plans
* Tasks
* Tests
* Chat
* Progress
* Notifications
* Content metadata

#### Supabase Auth

Responsible for:

* User registration
* Login
* Email verification
* Password reset
* Session management
* OAuth/social login where required

#### Supabase Realtime

Used for:

* Chat messages
* Subscription state changes
* Notifications
* Task updates
* Mentor/mentee interactions

#### Supabase Storage

Used for:

* Profile pictures
* PDFs
* Images
* Videos where appropriate
* Study materials
* Other educational assets

#### Edge Functions

Server-side business logic will be implemented using Edge Functions.

Examples:

* Razorpay webhook processing
* Payment verification
* Subscription activation
* Subscription expiry
* Notification triggers
* Scheduled jobs
* Secure third-party API communication

### Data Integrity

PostgreSQL will enforce:

* Foreign keys
* Unique constraints
* Check constraints
* Database indexes
* Triggers
* Row-Level Security policies

---

# 4. 🗄️ Database Architecture

The database is centered around users, exams, subscriptions, content, communication, and progress.

### Core Entities

```text
Users
 ├── Profiles
 ├── Subscriptions
 │     └── Payments
 │
 ├── Study Plans
 │     └── Tasks
 │
 ├── Progress
 │
 ├── Chat Rooms
 │     └── Messages
 │
 └── Notifications

Exams
 ├── FMGE
 ├── NEET PG
 └── INI-CET

Content
 ├── Documents
 ├── Videos
 ├── Tests
 └── Study Plans
```

### Primary Tables

* `users`
* `profiles`
* `exams`
* `subscriptions`
* `payments`
* `study_plans`
* `tasks`
* `study_materials`
* `tests`
* `test_questions`
* `test_attempts`
* `chat_rooms`
* `chat_messages`
* `progress_records`
* `announcements`
* `notifications`

### Database Principles

* Proper foreign-key relationships
* Appropriate indexing
* Soft deletion where required
* Audit fields (`created_at`, `updated_at`)
* Server-generated timestamps
* RLS policies for access control
* Database constraints for critical business rules

---

# 5. 🔐 Authentication Architecture

Authentication will be handled through **Supabase Auth**.

### Supported Authentication

Initially:

* Email + password
* Email verification
* Password reset

Potential future options:

* Google
* Apple
* Phone OTP

### Authentication Flow

```text
User
 │
 ▼
Flutter App
 │
 ▼
Supabase Auth
 │
 ├── Access Token
 └── Refresh Token
 │
 ▼
Authenticated API Requests
 │
 ▼
Supabase / Edge Functions
```

Authentication state will be maintained through the Supabase client and securely persisted on supported platforms.

---

# 6. 🛡️ Authorization Architecture

Authorization follows **Role-Based Access Control (RBAC)** combined with PostgreSQL Row-Level Security.

### Primary Roles

```text
                User
                  │
          ┌───────┴───────┐
          ▼               ▼
       Mentee           Mentor
```

### Mentee Permissions

Mentees can:

* View their own profile
* Manage their subscriptions
* Access subscribed content
* View their study plans
* Complete tasks
* Take tests
* View progress
* Chat with their mentor
* Receive notifications

### Mentor Permissions

Mentors can:

* Manage assigned mentees
* Create/update content
* Create study plans
* Assign tasks
* View mentee progress
* Send announcements
* Communicate with mentees
* View subscription-related information where permitted

### Security Principle

> **Client-side authorization is never considered sufficient.**

All sensitive authorization decisions must be enforced server-side using:

* PostgreSQL RLS
* Edge Functions
* Database constraints

---

# 7. 💳 Subscription Architecture

Subscriptions determine access to exam-specific mentorship programs.

### Supported Programs

* **FMGE**
* **NEET PG**
* **INI-CET**

### Subscription Lifecycle

```text
User
 │
 ▼
Select Exam
 │
 ▼
Select Subscription
 │
 ▼
Razorpay Checkout
 │
 ▼
Payment
 │
 ▼
Webhook
 │
 ▼
Edge Function
 │
 ▼
Payment Verification
 │
 ▼
Subscription Activated
 │
 ▼
Content Access Granted
```

### Subscription States

```text
PENDING
ACTIVE
PAUSED
EXPIRED
CANCELLED
```

Subscription access should always be determined from the **server-side subscription state**, rather than trusting the client application.

---

# 8. 💰 Payment Architecture

**Razorpay** will handle payment processing.

### Payment Flow

```text
Flutter App
     │
     ▼
Create Payment / Order
     │
     ▼
Razorpay Checkout
     │
     ▼
Payment Completed
     │
     ▼
Razorpay Webhook
     │
     ▼
Supabase Edge Function
     │
     ├── Verify Signature
     ├── Verify Payment
     └── Update Database
             │
             ▼
      Subscription Active
```

### Payment Records

Each payment should maintain:

* User ID
* Subscription ID
* Razorpay order ID
* Razorpay payment ID
* Amount
* Currency
* Status
* Payment timestamp
* Verification status
* Metadata

### Security

Razorpay secret credentials must **never** be included in the Flutter application.

---

# 9. 💬 Chat Architecture

The platform will provide one-to-one communication between mentors and mentees.

### Chat Model

```text
Mentor
   │
   │
   ▼
Chat Room
   │
   ├── Message
   ├── Message
   ├── Message
   └── Message
   │
   ▼
Mentee
```

### Features

* One-to-one messaging
* Realtime message delivery
* Message timestamps
* Read/unread state
* Message ordering
* Pagination
* Conversation history
* Online/offline handling
* Push notifications

### Realtime Flow

```text
Message Created
      │
      ▼
PostgreSQL
      │
      ▼
Supabase Realtime
      │
      ▼
Mentee / Mentor Client
      │
      ▼
UI Updated
```

An offline queue may be implemented to improve reliability during unstable network conditions.

---

# 10. 🔔 Notification Architecture

Push notifications will use **Firebase Cloud Messaging (FCM)**.

### Notification Sources

* New chat messages
* New announcements
* Study-plan updates
* Task deadlines
* Test availability
* Subscription events
* Payment events
* Mentor notifications

### Architecture

```text
Application Event
       │
       ▼
Supabase / Edge Function
       │
       ├──────────────┐
       ▼              ▼
Database          Firebase FCM
       │              │
       ▼              ▼
Notification      Push Message
History               │
                      ▼
                 User Device
```

Notification history will also be persisted for in-app viewing.

---

# 11. 📚 Content Architecture

Educational content will be structured around exams, subscriptions, and learning resources.

### Content Types

* 📄 Documents
* 🎥 Videos
* 📝 Tests
* 📅 Study Plans
* ✅ Tasks
* 📢 Announcements

### Content Hierarchy

```text
Exam
 │
 ├── Program
 │    │
 │    ├── Study Plan
 │    │    ├── Tasks
 │    │    └── Materials
 │    │
 │    ├── Videos
 │    ├── Documents
 │    └── Tests
 │
 └── Announcements
```

### Storage

Large files will be stored in **Supabase Storage**, while metadata and access rules will remain in PostgreSQL.

### Access Control

Content access will depend on:

```text
Authenticated User
        +
Active Subscription
        +
Correct Exam / Program
        =
Content Access
```

---

# 12. 🧪 Testing Architecture

Testing will occur across multiple layers.

### Unit Testing

Test:

* Business logic
* Repositories
* Providers
* Validators
* Utility functions

### Integration Testing

Test:

* Authentication
* Supabase integration
* Subscription flows
* Payment workflows
* Chat
* Notifications

### UI Testing

Critical user journeys will be covered with Flutter integration tests.

Examples:

```text
Registration
    ↓
Login
    ↓
Select Exam
    ↓
Purchase Subscription
    ↓
Access Content
    ↓
Chat With Mentor
```

### Backend Testing

Supabase Edge Functions will be tested locally using the Supabase CLI.

---

# 13. 🚀 CI/CD Architecture

CI/CD will use **GitHub Actions**.

### Pull Request Pipeline

```text
Pull Request
     │
     ├── Formatting
     ├── Static Analysis
     ├── Unit Tests
     ├── Integration Tests
     └── Build Verification
             │
             ▼
         PR Status
```

### Main Branch Pipeline

```text
Merge to Main
      │
      ├── Run Tests
      ├── Build Applications
      ├── Deploy Edge Functions
      ├── Apply Database Migrations
      └── Deploy Web Application
```

Mobile releases may initially remain manual/semi-automated through the respective app stores.

---

# 14. 🔒 Security Architecture

Security will be enforced across every layer.

### Application Security

* Secure authentication
* Secure token handling
* Input validation
* Secure local storage
* HTTPS-only communication

### Backend Security

* PostgreSQL Row-Level Security
* Server-side authorization
* Database constraints
* Rate limiting
* Audit logging
* Secure Edge Functions

### Secrets

The following must never be embedded in client applications:

* Razorpay secret keys
* Supabase service-role keys
* Firebase server credentials
* Third-party API secrets

Secrets should be managed using environment variables and appropriate secret-management systems.

### Payment Security

Payment verification must occur server-side.

### Data Security

Sensitive user information should follow the principle of:

> **Collect only what is required, store it securely, and expose only what the requesting role is authorized to access.**

---

# 15. 📂 Repository Architecture

The project will use a **monorepo** structure.

```text
/
├── apps/
│   ├── mentee/
│   │   └── Flutter Mentee Application
│   │
│   └── mentor/
│       └── Flutter Mentor Application
│
├── packages/
│   ├── core/
│   ├── models/
│   ├── repositories/
│   ├── networking/
│   ├── authentication/
│   ├── subscriptions/
│   └── ui/
│
├── backend/
│   └── supabase/
│       ├── functions/
│       ├── migrations/
│       └── seed/
│
├── docs/
│   ├── architecture.md
│   ├── api.md
│   ├── database.md
│   └── deployment.md
│
├── scripts/
│   ├── deployment/
│   └── development/
│
├── .github/
│   └── workflows/
│
└── README.md
```

### Benefits

* Shared code
* Consistent architecture
* Easier dependency management
* Centralized CI/CD
* Independent application development
* Clear module boundaries

---

# 16. 🗺️ Development Roadmap

Development will be divided into incremental phases.

### Phase 1 — Foundation

* Project setup
* Monorepo
* Flutter applications
* Supabase project
* Authentication
* User profiles
* RBAC

### Phase 2 — Exams & Subscriptions

* Exam selection
* Program structure
* Subscription plans
* Razorpay integration
* Payment verification
* Subscription access control

### Phase 3 — Mentorship

* Mentor profiles
* Mentee management
* One-to-one chat
* Realtime messaging
* Announcements

### Phase 4 — Learning

* Study plans
* Tasks
* Study materials
* Video content
* Content management

### Phase 5 — Assessments

* Tests
* Questions
* Test attempts
* Results
* Progress tracking

### Phase 6 — Notifications

* FCM integration
* Notification preferences
* In-app notification center
* Automated event notifications

### Phase 7 — Analytics

* Mentee analytics
* Mentor dashboard
* Engagement metrics
* Subscription analytics
* Learning progress

### Phase 8 — Production Hardening

* Performance optimization
* Security audit
* Automated deployments
* Monitoring
* Error tracking
* Production launch

---

# 17. 📌 Assumptions

The architecture currently assumes:

* Users have internet connectivity for realtime functionality.
* Razorpay supports all required payment and subscription scenarios.
* Supabase PostgreSQL can accommodate the expected initial data volume.
* Cupertino-first UI is appropriate for the Mentee mobile application.
* Supabase Realtime can support the expected initial messaging workload.
* Edge Functions are sufficient for server-side business logic.
* The Mentor application requires web and desktop support.

These assumptions should be validated during development.

---

# 18. ⚠️ Risks & Mitigation

| Risk                    | Impact | Mitigation                                           |
| ----------------------- | ------ | ---------------------------------------------------- |
| Supabase vendor lock-in | Medium | Repository abstraction + documented data model       |
| Payment failures        | High   | Webhooks + server-side verification + retry handling |
| Realtime scalability    | Medium | Pagination, indexing and architecture review         |
| Mentor app complexity   | Medium | Responsive component system + feature modules        |
| Data security           | High   | RLS + RBAC + server-side authorization               |
| Storage growth          | Medium | File limits + lifecycle policies                     |
| Regulatory requirements | High   | Legal/compliance review before production            |
| Third-party outages     | Medium | Retry mechanisms + graceful degradation              |

---

# 19. 🧠 Architectural Decisions

| Decision             | Choice             | Reason                                    |
| -------------------- | ------------------ | ----------------------------------------- |
| Mobile framework     | Flutter            | Cross-platform development                |
| Backend              | Supabase           | Integrated DB, Auth, Realtime and Storage |
| Database             | PostgreSQL         | Relational data + strong integrity        |
| State management     | Riverpod           | Testability and scalability               |
| Navigation           | GoRouter           | Declarative routing                       |
| Models               | Freezed            | Immutable, type-safe models               |
| Payments             | Razorpay           | Suitable for the Indian market            |
| Notifications        | Firebase FCM       | Cross-platform push notifications         |
| Architecture         | Clean Architecture | Maintainability and testability           |
| Repository structure | Monorepo           | Code reuse and centralized tooling        |
| Mentor platform      | Web + Desktop      | Better support for management workflows   |

---

# 20. ❓ Decisions Requiring Clarification

Before implementation reaches production, the following decisions need to be finalized.

### Business

* Subscription plans
* Pricing tiers
* Trial periods
* Renewal policies
* Refund policies
* Cancellation policies

### Roles & Permissions

* Mentor permissions
* Admin permissions
* Support staff permissions
* Multiple-mentor support
* Mentor-to-mentee assignment rules

### Content

* Supported file types
* Maximum upload size
* Video hosting strategy
* Content versioning
* Content expiry

### Offline Support

* Whether content should be downloadable
* Offline test support
* Offline study-plan access
* Offline chat behavior

### Analytics

* Metrics to track
* Data retention period
* Mentor analytics
* Business analytics
* User privacy requirements

### Scalability

* Expected initial users
* Expected concurrent users
* Expected daily messages
* Expected storage requirements
* Expected video bandwidth

---

# 🏁 Conclusion

The proposed architecture is designed to provide a **scalable, secure and maintainable foundation** for a medical mentorship platform serving FMGE, NEET PG and INI-CET aspirants.

The combination of:

**Flutter + Riverpod + Clean Architecture + Supabase + PostgreSQL + Razorpay + Firebase**

provides a unified technology stack capable of supporting:

* 📱 Cross-platform mentee applications
* 🖥️ Mentor web/desktop applications
* 👥 Mentor–mentee management
* 💳 Subscription payments
* 💬 Realtime communication
* 📚 Educational content delivery
* 📝 Assessments
* 📈 Progress tracking
* 🔔 Notifications
* 📊 Analytics

The architecture should remain modular so that individual services can be replaced or scaled independently as the platform grows.

---

> **Document Status:** 🟡 Architecture Draft
> **Version:** `1.0.0`
> **Last Updated:** September 2026

