using VidiVideo.Domain.Enums;

namespace VidiVideo.Api.Requests
{
    public sealed class VideoCreateRequest
    {
        public Guid CategoryId { get; init; }
        public string Caption { get; init; } = string.Empty;
        public VideoVisibility Visibility { get; init; }
        public bool IsPublished { get; init; }
        public int? EarlyAccessDays { get; init; }
        public IFormFile VideoFile { get; init; } = null!;
        public IFormFile ThumbnailFile { get; init; } = null!;
    }
}
