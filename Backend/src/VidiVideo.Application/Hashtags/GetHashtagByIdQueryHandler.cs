using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Hashtags
{
    public sealed class GetHashtagByIdQueryHandler : IQueryHandler<GetHashtagByIdQuery, HashtagDto>
    {
        private readonly IHashtagRepository _repo;

        public GetHashtagByIdQueryHandler(IHashtagRepository repo)
        {
            _repo = repo;
        }
        public async Task<HashtagDto> HandleAsync(GetHashtagByIdQuery query, CancellationToken cancellationToken)
        {
            var hashtag = await _repo.GetHashtagAsync(query.Id) ?? throw new NotFoundException("Hashtag doesn't exist"); ;

            return new HashtagDto(
                hashtag.Id,
                hashtag.Name);
        }
    }
}
