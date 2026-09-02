using VidiVideo.Domain.Common;
using VidiVideo.Domain.Constants;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Domain.Entities;

public sealed class AppUser : AuditableEntity
{
    public string UserName { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public string DisplayName { get; private set; } = string.Empty;
    public string? Bio { get; private set; }
    public string? AvatarUrl { get; private set; }
    public Guid? CountryId { get; private set; }
    public Country? Country { get; private set; } = null!;
    public UserStatus Status { get; private set; } = UserStatus.Active;
    public string Role { get; private set; } = AppRoles.User;
    public string? PayPalMerchantId { get; private set; }
    public bool HasConnectedPayPal => !string.IsNullOrWhiteSpace(PayPalMerchantId);
    public ICollection<Video> Videos { get; set; } = [];
    public ICollection<Follow> Following { get; set; } = [];
    public ICollection<Follow> Followers { get; set; } = [];
    public ICollection<Notification> Notifications { get; set; } = [];
    public ICollection<ChannelEmoji> ChannelEmojis { get; set; } = [];

    protected AppUser() { }

    public AppUser(string userName, string email, string passwordHash, string displayName, string role = AppRoles.User)
    {
        UserName = userName;
        DisplayName = displayName;
        PasswordHash = passwordHash;
        Role = role;
        Email = email;
    }

    public void UpdateProfile(string displayName, string? bio, Guid? countryId)
    {
        DisplayName = displayName;
        Bio = bio;
        CountryId = countryId;
    }

    public void UpdateAvatar(string avatarUrl)
    {
        AvatarUrl = avatarUrl;
    }

    public void UpdatePassword(string passwordHash)
    {
        PasswordHash = passwordHash;
    }

    public void ChangeStatus(UserStatus status)
    {
        Status = status;
    }

    public void UpdateRole(string role)
    {
        Role = role;
    }

    public void ConnectPayPal(string merchantId)
    {
        if (string.IsNullOrWhiteSpace(merchantId))
            throw new ArgumentException(
                "PayPal merchant ID is required.",
                nameof(merchantId));

        PayPalMerchantId = merchantId;
        UpdatedAtUtc = DateTime.UtcNow;
    }

}
