using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Recommendations;

public sealed class RecommendationCandidate
{
    public required Video Video { get; init; }
    public bool IsLocked { get; set; }
    public RecommendationScore Score { get; set; }
        = new(0, 0, 0);
}