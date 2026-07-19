using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.ContentReports
{
    public sealed class ReviewContentReportCommandHandler : ICommandHandler<ReviewContentReportCommand, Guid>
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

        public async Task<Guid> HandleAsync(ReviewContentReportCommand command, CancellationToken cancellationToken)
        {
            if (!_currentUser.IsInRole(AppRoles.Admin) || !_currentUser.IsInRole(AppRoles.Moderator))
                throw new UnauthorizedException("Unauthorized for this action");

            var adminId = _currentUser.UserId ?? throw new UnauthorizedException("Not logged in");

            var report = await _repo.GetByIdAsync(command.ReportId) ?? throw new NotFoundException("Doesn't exist");

            report.Review(adminId, command.ResolutionNote, command.Status);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return command.ReportId;

        }
    }
}
