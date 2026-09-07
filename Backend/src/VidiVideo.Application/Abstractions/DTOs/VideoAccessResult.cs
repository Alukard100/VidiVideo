namespace VidiVideo.Application.Abstractions.DTOs;

public sealed record VideoAccessResult(bool IsVisible, bool IsLocked, bool IsOwner);
