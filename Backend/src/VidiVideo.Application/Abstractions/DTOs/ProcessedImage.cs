namespace VidiVideo.Application.Abstractions.DTOs;

public sealed record ProcessedImage(byte[] Bytes, string Extension, string ContentType);

