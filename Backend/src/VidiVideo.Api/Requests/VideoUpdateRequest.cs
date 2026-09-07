using VidiVideo.Domain.Enums;

namespace VidiVideo.Api.Requests;

public sealed class VideoUpdateRequest
{
    public Guid VideoId { get; init; }

    public Guid CategoryId { get; init; }

    public string Caption { get; init; } = string.Empty;

    public VideoVisibility Visibility { get; init; }

    public bool IsPublished { get; init; }
}
