# VidiVideo

VidiVideo is a short-form video platform built for the **Razvoj Softvera II (RSII)** course project.

The system consists of a Flutter mobile client, a Flutter Windows administration client, a .NET 9 REST API, SQL Server, RabbitMQ, a background Worker service, PayPal Sandbox payments, PDF reporting, and an explainable recommendation system.

## Features

### Mobile application
- Registration and login with JWT authentication
- Recommended and following video feeds
- Video playback, likes and comments
- Search by text, category and hashtags
- Search history
- User profiles and profile editing
- Follow / unfollow creators
- Video creation and thumbnail selection
- Public and subscriber-only videos
- PayPal creator onboarding
- Creator subscriptions
- Subscriber-only content access
- Refund requests
- Notifications
- Explainable recommendations

### Desktop administration application
- Dashboard and system statistics
- Platform revenue and transaction statistics
- User management
- Staff management
- Content moderation
- Refund request approval / rejection
- Revenue analytics PDF report
- Video analytics PDF report

### Backend and infrastructure
- .NET 9 / ASP.NET Core REST API
- Entity Framework Core with SQL Server
- JWT authentication and role-based authorization
- CQRS-style Commands and Queries
- Repository and Unit of Work patterns
- RabbitMQ messaging
- Separate Worker service
- Docker Compose
- PayPal Sandbox multiparty payments
- QuestPDF report generation
- Paginated list endpoints

## Project Structure

```text
Backend/
  src/
    VidiVideo.Api/
    VidiVideo.Application/
    VidiVideo.Domain/
    VidiVideo.Infrastructure/
    VidiVideo.Worker/

Frontend/
  lib/

recommender-dokumentacija.md
docker-compose.yml
.env.example
```

## Configuration

Copy:

```text
.env.example
```

to:

```text
.env
```

and replace all placeholder values.

Important configuration includes:

- SQL Server SA password
- database connection string password
- JWT signing key
- RabbitMQ credentials
- PayPal Sandbox Client ID and Secret
- PayPal partner configuration

The SQL Server password in the connection string must match the configured SQL Server SA password.

The RabbitMQ credentials used by the API and Worker must match the credentials used by the RabbitMQ container.

## Starting the Backend

From the repository root:

```powershell
docker compose up -d --build
```

Check container status:

```powershell
docker compose ps
```

Docker starts:

- SQL Server
- RabbitMQ
- VidiVideo API
- VidiVideo Worker

The API is exposed on:

```text
http://localhost:5000
```

## Running the Flutter Application

### Windows

From the `Frontend` directory:

```powershell
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5000
```

Release build:

```powershell
flutter build windows --release --dart-define=API_BASE_URL=http://localhost:5000
```

Output:

```text
Frontend/build/windows/x64/runner/Release/
```

### Android Emulator

Run:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Release APK:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

Output:

```text
Frontend/build/app/outputs/flutter-apk/app-release.apk
```

## Development Accounts

The database is seeded automatically on first startup.

| Context | Username | Password |
| --- | --- | --- |
| Desktop version | `desktop` | `test` |
| Mobile version | `mobile` | `test` |
| Admin role | `admin` | `test` |

## PayPal Sandbox

VidiVideo uses PayPal Sandbox for creator subscriptions.

Current payment model:

- subscription price: **5.00 USD**
- VidiVideo platform fee: **1.00 USD**
- the remaining amount is assigned to the creator before PayPal processing fees

Creators must connect an eligible PayPal Sandbox Business account before publishing subscriber-only content.

Refunds are performed through the original PayPal capture. Refund contribution of the platform fee through `payment_instruction.platform_fees` requires an additional PayPal Commerce Platform capability that is not enabled on the sandbox partner account used for this project.

## RabbitMQ Worker

RabbitMQ is used for asynchronous background processing.

The Worker consumes image-cleanup messages and removes orphaned images after avatar or thumbnail replacement when an image is no longer referenced by the application.

The API and Worker share the image storage volume through Docker.

## Reporting

Administrators can generate:

- Revenue Analytics Report
- Video Analytics Report

Revenue reporting distinguishes between:

- total transaction value
- VidiVideo platform revenue
- completed payments
- active subscriptions

Reports support optional date filtering and are generated with QuestPDF.

## Recommendation System

VidiVideo includes a hybrid and explainable recommendation system based on:

- content-based relevance
- collaborative signals
- popularity and engagement
- video recency
- likes
- watch completion
- followed creators
- subscriptions
- category and hashtag affinity
- country affinity

The system also supports cold-start users and guest recommendations.

Detailed documentation is available in:

```text
recommender-dokumentacija.md
```

## Technology Stack

### Backend
- .NET 9
- ASP.NET Core
- Entity Framework Core
- SQL Server
- JWT
- BCrypt
- RabbitMQ
- QuestPDF
- Docker

### Frontend
- Flutter
- Android
- Windows

## Recommended Startup Order

```text
1. Configure .env
2. docker compose up -d --build
3. Start the Windows application or Android emulator application
```

Both clients communicate with the same API running in Docker.
