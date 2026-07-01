using VidiVideo.Application.Abstractions;
using VidiVideo.Domain.Constants;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Seed;

public sealed class DatabaseSeeder
{
    private readonly VidiVideoDbContext _db;
    private readonly IPasswordHasher _passwordHasher;

    public DatabaseSeeder(VidiVideoDbContext db, IPasswordHasher passwordHasher)
    {
        _db = db;
        _passwordHasher = passwordHasher;
    }

    public async Task SeedAsync()
    {
        var users = new[]
        {
            new AppUser(
                "desktop",
                "desktop",
                _passwordHasher.Hash("test"),
                AppRoles.User,
                "fakemailDesktop@mail.com"),

            new AppUser(
                "mobile",
                "mobile",
                _passwordHasher.Hash("test"),
                AppRoles.User,
                "fakemailMobile@mail.com"),

            new AppUser(
                "admin",
                "Administrator",
                _passwordHasher.Hash("test"),
                AppRoles.Admin,
                "fakemailAdmin@mail.com")
        };

        var categories = new[]
        {
            new Category("Gaming"),
            new Category("Music"),
            new Category("Education"),
            new Category("Comedy"),
            new Category("Sports"),
            new Category("Technology"),
            new Category("Travel"),
            new Category("News"),
            new Category("Entertainment"),
            new Category("Lifestyle"),
            new Category("Pop Culture"),
            new Category("Creative"),
            new Category("Business"),
            new Category("Food"),
            new Category("Vehicles"),
            new Category("Nature"),
            new Category("Fun")
        };

        var coutnries = new[]
        {
            new Country("Bosnia and Herzegovina", "BIH"),
            new Country("Australia", "AUS"),
            new Country("Austria", "AUT"),
            new Country("Brazil", "BRA"),
            new Country("Canada", "CAN"),
            new Country("China", "CHN"),
            new Country("Germany", "DEU"),
            new Country("India", "IND"),
            new Country("Japan", "JPN"),
            new Country("United Kingdom", "GBR"),
            new Country("United States", "USA"),
            new Country("Croatia", "HRV"),
            new Country("Serbia", "SRB"),
            new Country("Italy", "ITA"),
            new Country("Spain", "ESP"),
            new Country("Switzerland", "CHE"),
            new Country("Netherlands", "NLD"),
            new Country("Greece", "GRC"),
            new Country("Portugal", "PRT"),
            new Country("Sweden", "SWE"),
            new Country("Norway", "NOR"),
            new Country("Mexico", "MEX"),
            new Country("South Korea", "KOR"),
            new Country("South Africa", "ZAF"),
            new Country("Egypt", "EGY")
        };

        if (!_db.Users.Any())
            await _db.Users.AddRangeAsync(users);


        if (!_db.Categories.Any())
            await _db.Categories.AddRangeAsync(categories);


        if (!_db.Countrys.Any())
            await _db.Countrys.AddRangeAsync(coutnries);

        await _db.SaveChangesAsync();
    }
}
