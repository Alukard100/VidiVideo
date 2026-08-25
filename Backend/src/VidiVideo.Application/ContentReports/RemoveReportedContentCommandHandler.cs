using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.ContentReports;

public sealed class RemoveReportedContentCommandHandler : ICommandHandler<RemoveReportedContentCommand, bool>
{
    private readonly IVideoRepository _videoRepo;
    private readonly ICommentRepository _commentRepo;
    private readonly IUnitOfWork _unitOfWork;
    public RemoveReportedContentCommandHandler(IVideoRepository videoRepo, ICommentRepository commentRepo, IUnitOfWork unitOfOwrk)
    {
        _videoRepo = videoRepo;
        _commentRepo = commentRepo;
        _unitOfWork = unitOfOwrk;
    }

    public async Task<bool> HandleAsync(RemoveReportedContentCommand command, CancellationToken cancellationToken)
    {
        var isVideo = command.ContentType.Equals(
            "video",
            StringComparison.OrdinalIgnoreCase);

        var isComment = command.ContentType.Equals(
            "comment",
            StringComparison.OrdinalIgnoreCase);

        if (!isVideo && !isComment)
        {
            throw new ValidationException(
                "Invalid content type.");
        }


        if (isVideo)
        {
            var item = await _videoRepo.GetVideoByIdAsync(command.ContentId, cancellationToken) ?? throw new NotFoundException("Doesn't exist");
            item.Remove();
        }
        else
        {
            var item = await _commentRepo.GetCommentByIdAsync(command.ContentId) ?? throw new NotFoundException("Doesn't exist");
            item.Remove();
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;


    }
}
