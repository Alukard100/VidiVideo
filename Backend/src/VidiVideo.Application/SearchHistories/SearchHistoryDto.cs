namespace VidiVideo.Application.SearchHistories;

public sealed record SearchHistoryDto(Guid Id, Guid UserId, string Query, DateTime CreatedAtUtc);

