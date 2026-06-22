namespace VidiVideo.Application.Abstractions
{
    public interface IVideoStorageService
    {
        Task<string> UploadAsync(Stream videoFile, string videoName);
    }
}
