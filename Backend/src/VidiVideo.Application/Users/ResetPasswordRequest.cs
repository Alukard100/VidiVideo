namespace VidiVideo.Application.Users;

public sealed record ResetPasswordRequest(string Email, string Code, string NewPassword);
