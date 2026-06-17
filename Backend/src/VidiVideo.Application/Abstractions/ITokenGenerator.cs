using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions
{
    public interface ITokenGenerator
    {
        string GenerateToken(AppUser user);
    }
}
