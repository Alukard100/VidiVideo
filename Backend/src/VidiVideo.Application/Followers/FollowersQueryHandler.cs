using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Followers
{
    public sealed class FollowersQueryHandler : IQueryHandler<FollowersQuery, PagedResult<UserFollowDto>>
    {
        private readonly IFollowersRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUser _currentUser;

        public FollowersQueryHandler(IFollowersRepository repo, IUserRepository userRepository, ICurrentUser currentUser)
        {
            _repo = repo;
            _userRepository = userRepository;
            _currentUser = currentUser;
        }

        public async Task<PagedResult<UserFollowDto>> HandleAsync(FollowersQuery query, CancellationToken cancellationToken)
        {
            var currentUserId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in.");

            if (!await _userRepository.ExistsByIdAsync(query.TargetUserId)) throw new NotFoundException("Target user doesn't exist.");

            var count = await _repo.CountFollowersAsync(query.TargetUserId);
            var items = await _repo.ViewFollowersAsync(currentUserId, query.TargetUserId, query.Page, query.PageSize);

            return new PagedResult<UserFollowDto>(items, query.Page, query.PageSize, count);
        }
    }
}
