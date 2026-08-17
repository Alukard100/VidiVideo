namespace VidiVideo.Application.Abstractions
{
    public interface IVideoStorageService
    {
        Task<string> UploadAsync(Stream videoFile, string videoName, CancellationToken cancellationToken = default);
        Task<Stream> OpenReadAsync(string storageKey, CancellationToken cancellationToken = default);
        string GetContentType(string storageKey);
    }
}
