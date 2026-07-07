using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Videos.Likes;

public sealed class LikeVideoCommandHandler : ICommandHandler<LikeVideoCommand, LikeDto>
{
    private readonly ILikeRepository _repo;
    private readonly IVideoRepository _videoRepository;
    private readonly IUserRepository _userRepository;
    private readonly IUnitOfWork _unitOfWork;
    public LikeVideoCommandHandler(ILikeRepository repo, IUnitOfWork unitOfWork, IVideoRepository videoRepoisotry, IUserRepository userRepository)
    {
        _repo = repo;
        _unitOfWork = unitOfWork;
        _videoRepository = videoRepoisotry;
        _userRepository = userRepository;
    }

    public async Task<LikeDto> HandleAsync(LikeVideoCommand command, CancellationToken cancellationToken)
    {
        _ = await _videoRepository.GetVideoByIdAsync(command.videoId) ?? throw new NotFoundException("Video doesn't exist");
        if (!await _userRepository.ExistsByIdAsync(command.userId))
            throw new NotFoundException("You must login to like");

        if (await _repo.IsLikedByCurrentUser(command.videoId, command.userId))
            throw new ConflictException("Video is already liked");

        var like = new Like
        {
            VideoId = command.videoId,
            UserId = command.userId
        };

        await _repo.LikeVideoAsync(like);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return new LikeDto(command.videoId, command.userId);
    }
}
