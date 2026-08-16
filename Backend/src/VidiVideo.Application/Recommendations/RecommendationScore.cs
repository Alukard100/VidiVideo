namespace VidiVideo.Application.Recommendations;

public sealed record RecommendationScore(
    double Content,
    double Collaborative,
    double Popularity)
{
    public double Total =>
        Content * 0.45 +
        Collaborative * 0.30 +
        Popularity * 0.25;
}