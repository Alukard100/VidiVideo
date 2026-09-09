using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Application.ContentReports
{
    public sealed class ReviewContentReportCommandHandler : ICommandHandler<ReviewContentReportCommand, bool>
    {
        private readonly IContentReportRepository _repo;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUser _currentUser;
        public ReviewContentReportCommandHandler(IContentReportRepository repo, IUnitOfWork unitOfWork, ICurrentUser currentUser)
        {
            _repo = repo;
            _unitOfWork = unitOfWork;
            _currentUser = currentUser;
        }

        public async Task<bool> HandleAsync(ReviewContentReportCommand command, CancellationToken cancellationToken)
        {
            if (!Enum.IsDefined(command.Status))
            {
                throw new ValidationException(
                    "Invalid report status.");
            }

            if (command.Status == ReportStatus.Pending)
            {
                throw new ValidationException(
                    "Reviewed report cannot remain pending.");
            }

            if (command.ResolutionNote?.Length > 500)
            {
                throw new ValidationException(
                    "Resolution note cannot exceed 500 characters.");
            }

            var reviewerId = _currentUser.UserId
                ?? throw new UnauthorizedException(
                    "Not logged in.");

            var isVideo = string.Equals(command.ContentType,
                "video",
                StringComparison.OrdinalIgnoreCase);

            var isComment = string.Equals(command.ContentType,
                "comment",
                StringComparison.OrdinalIgnoreCase);

            if (!isVideo && !isComment)
            {
                throw new ValidationException(
                    "Invalid content type.");
            }

            var reports = await _repo.GetByContentAsync(
                command.ContentId,
                isVideo,
                cancellationToken);

            var pendingReports = reports
                .Where(r => r.Status == ReportStatus.Pending)
                .ToList();

            if (pendingReports.Count == 0)
            {
                throw new NotFoundException(
                    "No pending reports found for this content.");
            }

            foreach (var report in pendingReports)
            {
                report.Review(
                    reviewerId,
                    command.ResolutionNote!,
                    command.Status);
            }

            await _unitOfWork.SaveChangesAsync(
                cancellationToken);

            return true;
        }

    }
}

