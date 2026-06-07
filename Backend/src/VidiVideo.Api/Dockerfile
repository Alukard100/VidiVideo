FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY VidiVideo.sln ./
COPY Backend/src/VidiVideo.Api/VidiVideo.Api.csproj Backend/src/VidiVideo.Api/
COPY Backend/src/VidiVideo.Application/VidiVideo.Application.csproj Backend/src/VidiVideo.Application/
COPY Backend/src/VidiVideo.Domain/VidiVideo.Domain.csproj Backend/src/VidiVideo.Domain/
COPY Backend/src/VidiVideo.Infrastructure/VidiVideo.Infrastructure.csproj Backend/src/VidiVideo.Infrastructure/
RUN dotnet restore Backend/src/VidiVideo.Api/VidiVideo.Api.csproj
COPY . .
RUN dotnet publish Backend/src/VidiVideo.Api/VidiVideo.Api.csproj -c Release -o /app/publish --no-restore

FROM runtime AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "VidiVideo.Api.dll"]
