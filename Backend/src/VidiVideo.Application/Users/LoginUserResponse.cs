namespace VidiVideo.Application.Users
{
    public sealed record LoginUserResponse(
        Guid Id,
        string UserName,
        string Role,
        string token);
}
