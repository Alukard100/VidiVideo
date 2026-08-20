using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Common;

public static class PasswordValidator
{
    public static void Validate(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
        {
            throw new ValidationException(
                "Password is required.");
        }

        if (password.Length < 8)
        {
            throw new ValidationException(
                "Password must contain at least 8 characters.");
        }

        if (!password.Any(char.IsUpper))
        {
            throw new ValidationException(
                "Password must contain at least one uppercase letter.");
        }

        if (!password.Any(char.IsLower))
        {
            throw new ValidationException(
                "Password must contain at least one lowercase letter.");
        }

        if (!password.Any(char.IsDigit))
        {
            throw new ValidationException(
                "Password must contain at least one number.");
        }
    }
}