using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Followers
{
    public sealed class FollowingQueryHandler : IQueryHandler<FollowingQuery, PagedResult<UserFollowDto>>
    {
        private readonly IFollowersRepository _repo;
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUser _currentUser;
        public FollowingQueryHandler(IFollowersRepository repo, IUserRepository userRepository, ICurrentUser currentUser)
        {
            _repo = repo;
            _userRepository = userRepository;
            _currentUser = currentUser;
        }

        public async Task<PagedResult<UserFollowDto>> HandleAsync(FollowingQuery query, CancellationToken cancellationToken)
        {
            var currentUserId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in.");

            if (!await _userRepository.ExistsByIdAsync(query.TargetUserId)) throw new NotFoundException("Target user doesn't exist");

            var count = await _repo.CountFollowingAsync(query.TargetUserId);
            var items = await _repo.ViewFollowingAsync(currentUserId, query.TargetUserId, query.Page, query.PageSize);

            return new PagedResult<UserFollowDto>(items, query.Page, query.PageSize, count);

        }
    }
}
