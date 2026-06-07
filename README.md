# VidiVideo

VidiVideo is a short-form video platform for creators, followers, premium subscriptions, content moderation, and explainable recommendations.

## Important Course Notes

The submitted topic mentions desktop and mobile applications. The 2025/26 RS2 instructions explicitly require Flutter for desktop and mobile builds, so the client starter is Flutter-based.

Required items already reflected in the architecture:

- .NET 9 REST API.
- CQRS-friendly Application layer.
- Entity Framework Core with SQL Server.
- JWT-ready authentication setup.
- Separate Worker project for asynchronous processing.
- RabbitMQ and SQL Server in `docker-compose.yml`.
- `.env` based configuration.
- Recommender documentation file.

## Structure

```text
Backend/
  src/
    VidiVideo.Api/             REST API and HTTP concerns
    VidiVideo.Application/     CQRS contracts, DTOs, application services
    VidiVideo.Domain/          Entities, enums, constants
    VidiVideo.Infrastructure/  EF Core, persistence, messaging
    VidiVideo.Worker/          Separate worker service
Frontend/
  lib/                         Flutter desktop/mobile starter
```

## Getting Started

1. Copy `.env.example` to `.env`.
2. Replace the JWT key and database password values.
3. Start infrastructure and services:

```powershell
docker compose up --build
```

4. Run the Flutter starter:

```powershell
cd Frontend
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5000
```

For Android emulator networking, use:

```powershell
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

If this folder was created before Flutter was installed, generate platform folders from inside `Frontend`:

```powershell
flutter create . --platforms=android,windows
flutter pub get
```

## Development Accounts

Seed users are not implemented yet. The final README must include the course-required credentials:

| Context | Username | Password |
| --- | --- | --- |
| Desktop version | desktop | test |
| Mobile version | mobile | test |
| Admin role | admin | test |

## Next Backend Milestones

1. Add authentication endpoints and password hashing.
2. Add migrations and seed data for `190103`.
3. Implement CRUD endpoints for reference data.
4. Implement video upload metadata, comments, likes, follows, reports, and subscriptions.
5. Implement PayPal sandbox payment verification on the server side.
6. Replace worker heartbeat with real notification/email processing from RabbitMQ.
7. Add two PDF reports for the admin application.
