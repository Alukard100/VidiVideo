using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Abstractions.Repositories;

public interface IChannelEmojiRepository
{
    Task<ChannelEmoji?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<ChannelEmoji?> GetByCreatorAndCodeAsync(Guid creatorId, string code, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ChannelEmoji>> GetByCreatorAsync(Guid creatorId, int page = 1, int pageSize = 3, CancellationToken cancellationToken = default);
    Task<int> CountByCreatorAsync(Guid creatorId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ChannelEmoji>> GetAvailableForUserAsync(Guid userId, int page = 1, int pageSize = 16, CancellationToken cancellationToken = default);
    Task<int> CountAvailableForUserAsync(Guid userId, CancellationToken cancellationToken = default);
    Task AddAsync(ChannelEmoji emoji, CancellationToken cancellationToken = default);
    void Remove(ChannelEmoji emoji);
}
