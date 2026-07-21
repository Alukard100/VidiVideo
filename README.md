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

## Features

### Authentication
- JWT authentication
- Role-based authorization
- BCrypt password hashing
- Current user abstraction

### Video Management
- Upload video metadata
- Update video
- Delete video
- Pagination
- Search
- Category filtering
- Hashtag filtering
- Video visibility
- Publish / unpublish

### Social Features
- Like / Unlike videos
- Follow / Unfollow creators
- Comments
- Search history
- Video watch history
- Notifications

### Creator Features
- Creator subscriptions
- Premium subscriptions
- PayPal Sandbox integration
- Payment verification

### Moderation
- Content reports
- Review reports
- Admin moderation endpoints

### Reports
- Revenue Analytics PDF
- Video Analytics PDF

### Infrastructure
- RabbitMQ
- SQL Server
- CQRS architecture
- Docker Compose

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

The database is seeded automatically on first startup.

| Context | Username | Password |
| --- | --- | --- |
| Desktop version | desktop | test |
| Mobile version | mobile | test |
| Admin role | admin | test |

## Backend Status

Implemented:

- Authentication
- Authorization
- Seed data
- CRUD endpoints
- Categories
- Countries
- Hashtags
- Videos
- Comments
- Likes
- Follows
- Notifications
- Search History
- Video Views
- Content Reports
- Creator Subscriptions
- Payments
- PayPal Sandbox verification
- Revenue PDF report
- Video Analytics PDF report

## API Overview

Main endpoints include:

- Authentication
- Users
- Videos
- Categories
- Countries
- Hashtags
- Comments
- Likes
- Follows
- Notifications
- Search History
- Video Views
- Reports
- PayPal

## Technologies

Backend

- .NET 9
- ASP.NET Core
- Entity Framework Core
- SQL Server
- JWT
- BCrypt
- RabbitMQ
- QuestPDF
- FFMpegCore

Frontend

- Flutter

## Architecture

The backend follows a layered architecture.

- Domain
- Application
- Infrastructure
- API
- Worker

Application logic is implemented using CQRS with Commands and Queries.

Persistence is handled through repositories and a Unit of Work.

Authentication is based on JWT access tokens.

Background processing is handled through RabbitMQ.

## Reporting

The administrator can generate PDF reports.

Available reports:

- Revenue Analytics Report
- Video Analytics Report

Reports support optional date filtering and are generated using QuestPDF.

