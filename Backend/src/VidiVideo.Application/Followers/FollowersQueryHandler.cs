using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Followers
{
    public sealed class FollowersQueryHandler : IQueryHandler<FollowersQuery, PagedResult<UserFollowDto>>
    {
        private readonly IFollowersRepository _repo;
        private readonly IUserRepository _userRepository;

        public FollowersQueryHandler(IFollowersRepository repo, IUserRepository userRepository)
        {
            _repo = repo;
            _userRepository = userRepository;
        }

        public async Task<PagedResult<UserFollowDto>> HandleAsync(FollowersQuery query, CancellationToken cancellationToken)
        {
            if (query.CurrentUserId == query.TargetUserId)
            {
                if (!await _userRepository.ExistsByIdAsync(query.CurrentUserId))
                    throw new NotFoundException("You must be logged in");
            }
            else
            {
                if (!await _userRepository.BothUsersExistsById(query.CurrentUserId, query.TargetUserId))
                    throw new NotFoundException("Users don't exist");
            }

            var count = await _repo.CountFollowersAsync(query.TargetUserId);
            var items = await _repo.ViewFollowersAsync(query.CurrentUserId, query.TargetUserId, query.Page, query.PageSize);

            return new PagedResult<UserFollowDto>(items, query.Page, query.PageSize, count);
        }
    }
}
