using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Users.Administrative;

public sealed class DeleteStaffCommandHandler : ICommandHandler<DeleteStaffCommand, bool>
{
    private readonly ICurrentUser _currentUser;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IUserRepository _userRepository;
    public DeleteStaffCommandHandler(ICurrentUser currentUser, IUnitOfWork unitOfWork, IUserRepository userRepository)
    {
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
        _userRepository = userRepository;
    }

    public async Task<bool> HandleAsync(DeleteStaffCommand command, CancellationToken cancellationToken)
    {
        var targetUser = await _userRepository.GetByIdAsync(command.TargetId) ?? throw new NotFoundException("Target doesn't exist");

        if (targetUser.Role == AppRoles.SuperAdmin)
            throw new UnauthorizedException("Not allowed");

        if (targetUser.Role == AppRoles.Admin && !_currentUser.IsInRole(AppRoles.SuperAdmin))
            throw new UnauthorizedException("Not allowed");

        if (targetUser.Role == AppRoles.Moderator && !(_currentUser.IsInRole(AppRoles.SuperAdmin) || _currentUser.IsInRole(AppRoles.Admin)))
            throw new UnauthorizedException("Not allowed");

        await _userRepository.DeleteAsync(command.TargetId, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;

    }
}
