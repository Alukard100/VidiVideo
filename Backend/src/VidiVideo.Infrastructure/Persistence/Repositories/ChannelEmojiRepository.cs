using Microsoft.EntityFrameworkCore;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Infrastructure.Persistence.Repositories;

public sealed class ChannelEmojiRepository : IChannelEmojiRepository
{
    private readonly VidiVideoDbContext _db;
    public ChannelEmojiRepository(VidiVideoDbContext db)
    {
        _db = db;
    }

    public async Task AddAsync(ChannelEmoji emoji, CancellationToken cancellationToken)
    {
        await _db.ChannelEmojis.AddAsync(emoji, cancellationToken);
    }

    public async Task<int> CountAvailableForUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;

        var subscribedCreatorIds = _db.CreatorSubscriptions.Where(x => x.SubscriberId == userId && x.IsActive && x.EndsAtUtc > now).Select(x => x.CreatorId);

        return await _db.ChannelEmojis.CountAsync(x => !x.IsDeleted && (x.CreatorId == userId || subscribedCreatorIds.Contains(x.CreatorId)), cancellationToken);
    }

    public async Task<int> CountByCreatorAsync(Guid creatorId, CancellationToken cancellationToken)
        => await _db.ChannelEmojis.CountAsync(x => x.CreatorId == creatorId && !x.IsDeleted, cancellationToken);

    public async Task<IReadOnlyList<ChannelEmoji>> GetAvailableForUserAsync(Guid userId, int page, int pageSize, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;

        var subscribedCreatorIds = _db.CreatorSubscriptions.Where(x => x.SubscriberId == userId && x.IsActive && x.EndsAtUtc > now).Select(x => x.CreatorId);

        return await _db.ChannelEmojis
            .AsNoTracking()
            .Include(x => x.Creator)
            .Where(x => !x.IsDeleted && (x.CreatorId == userId || subscribedCreatorIds.Contains(x.CreatorId)))
            .OrderBy(x => x.Creator.DisplayName)
            .ThenBy(x => x.Code)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

    }

    public async Task<ChannelEmoji?> GetByCreatorAndCodeAsync(Guid creatorId, string code, CancellationToken cancellationToken)
    {
        return await _db.ChannelEmojis.FirstOrDefaultAsync(x => x.CreatorId == creatorId && x.Code == code && !x.IsDeleted, cancellationToken);
    }

    public async Task<IReadOnlyList<ChannelEmoji>> GetByCreatorAsync(Guid creatorId, int page, int pageSize, CancellationToken cancellationToken)
    {
        return await _db.ChannelEmojis
            .AsNoTracking()
            .Where(x => x.CreatorId == creatorId && !x.IsDeleted)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<ChannelEmoji?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        return await _db.ChannelEmojis.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public void Remove(ChannelEmoji emoji)
    {
        emoji.Remove();
    }
}
