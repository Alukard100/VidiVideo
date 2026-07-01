using VidiVideo.Domain.Common;
using VidiVideo.Domain.Constants;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class AppUser : AuditableEntity
{
    public string UserName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? AvatarUrl { get; set; }
    public Guid? CountryId { get; set; }
    public Country? Country { get; set; } = null!;
    public UserStatus Status { get; set; } = UserStatus.Active;
    public string Role { get; set; } = AppRoles.User;

    public ICollection<Video> Videos { get; set; } = [];
    public ICollection<Follow> Following { get; set; } = [];
    public ICollection<Follow> Followers { get; set; } = [];
    public ICollection<Notification> Notifications { get; set; } = [];

    protected AppUser() { }

    public AppUser(string userName, string email, string passwordHash, string displayName, string role = AppRoles.User)
    {
        UserName = userName;
        DisplayName = displayName;
        PasswordHash = passwordHash;
        Role = role;
        Email = email;
    }

}
