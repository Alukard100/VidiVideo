namespace VidiVideo.Infrastructure.Media;

public sealed record ImageProcessingOptions(
    int MaxWidth,
    int MaxHeight,
    int OutputMaxWidth,
    int OutputMaxHeight,
    int Quality = 80,
    bool CropToSquare = false);
