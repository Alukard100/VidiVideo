namespace VidiVideo.Application.Users.Administrative;

public sealed record AddStaffRequest(string UserName,
  string Email,
  string Password,
  string DisplayName,
  string Role);
