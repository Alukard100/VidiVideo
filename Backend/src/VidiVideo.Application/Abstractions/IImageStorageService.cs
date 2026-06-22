namespace VidiVideo.Application.Abstractions
{
    public interface IImageStorageService
    {
        Task<string> UploadAsync(Stream fileStream, string fileName);
    }
}