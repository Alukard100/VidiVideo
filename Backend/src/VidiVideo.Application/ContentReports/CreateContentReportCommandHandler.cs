using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.ContentReports
{
    public sealed class CreateContentReportCommandHandler : ICommandHandler<CreateContentReportCommand, System.Guid>
    {
        private readonly IContentReportRepository _repo;
        private readonly ICommentRepository _commentRepository;
        private readonly IVideoRepository _videoRepository;
        private readonly ICurrentUser _currentUser;
        private readonly IUnitOfWork _unitOfWork;
        public CreateContentReportCommandHandler(IContentReportRepository repo, ICommentRepository commentRepository, ICurrentUser currentUser, IVideoRepository videoRepository, IUnitOfWork unitOfWork)
        {
            _repo = repo;
            _commentRepository = commentRepository;
            _currentUser = currentUser;
            _videoRepository = videoRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<System.Guid> HandleAsync(CreateContentReportCommand command, CancellationToken cancellationToken)
        {
            if (command.CommentId == null && command.VideoId == null)
                throw new ValidationException("Invalid request");

            var creatorId = _currentUser.UserId ?? throw new UnauthorizedException("Must be logged in");

            if (command.CommentId is System.Guid commentId)
                if (!await _commentRepository.ExistsByIdAsync(commentId))
                    throw new NotFoundException("Invalid request");

            if (command.VideoId is System.Guid videoId)
                if (!await _videoRepository.ExistsByIdAsync(videoId))
                    throw new NotFoundException("Invalid request");

            var report = new Domain.Entities.ContentReport(creatorId, command.VideoId, command.CommentId, command.Reason);

            await _repo.CreateAsync(report);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return report.Id;

        }
    }
}
