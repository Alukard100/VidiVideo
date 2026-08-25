using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Constants;

namespace VidiVideo.Application.Users.Administrative;

public sealed class UpdateStaffRoleCommandHandler : ICommandHandler<UpdateStaffRoleCommand, bool>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUser _currentUser;
    private readonly IUserRepository _userRepository;
    public UpdateStaffRoleCommandHandler(IUnitOfWork unitOfWork, ICurrentUser currentUser, IUserRepository userRepository)
    {
        _unitOfWork = unitOfWork;
        _currentUser = currentUser;
        _userRepository = userRepository;
    }

    public async Task<bool> HandleAsync(UpdateStaffRoleCommand command, CancellationToken cancellationToken)
    {
        var target = await _userRepository.GetByIdAsync(command.TargetId) ?? throw new NotFoundException("User not found");

        if (!_currentUser.IsInRole(AppRoles.SuperAdmin))
            throw new UnauthorizedException("Not allowed");

        if (target.Role == AppRoles.SuperAdmin)
            throw new UnauthorizedException("Not allowed");

        target.UpdateRole(command.Role);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return true;

    }
}
