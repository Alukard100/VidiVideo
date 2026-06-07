namespace VidiVideo.Application.Abstractions;

public interface ICurrentUser
{
    Guid? UserId { get; }
    bool IsInRole(string role);
}
