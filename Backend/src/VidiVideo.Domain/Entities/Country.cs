using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Country : AuditableEntity
{
    public string Name { get; private set; } = string.Empty;
    public string Code { get; private set; } = string.Empty;

    public ICollection<AppUser> Users { get; set; } = [];

    protected Country() { }

    public Country(string name, string code)
    {
        Name = name;
        Code = code.ToUpperInvariant();
    }
    public void Update(string name, string code)
    {
        Name = name;
        Code = code.ToUpperInvariant();
    }
}
