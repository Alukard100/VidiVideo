using VidiVideo.Domain.Common;

namespace VidiVideo.Domain.Entities;

public sealed class Category : AuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public ICollection<Video> Videos { get; private set; } = [];

    protected Category() { }

    public Category(string name)
    {
        Name = name;
    }

    public void Update(string name)
    {
        this.Name = name;
    }

}
