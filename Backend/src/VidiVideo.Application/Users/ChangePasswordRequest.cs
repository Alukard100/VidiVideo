namespace VidiVideo.Application.Users;

public sealed record ChangePasswordRequest(
    string OldPassword,
    string NewPassword);
