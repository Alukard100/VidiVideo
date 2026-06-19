using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Hashtags
{
    public sealed class DeleteHashtagCommandHandler : ICommandHandler<DeleteHashtagCommand, bool>
    {
        private readonly IHashtagRepository _hashtagRepository;
        private readonly IUnitOfWork _unitOfWork;

        public DeleteHashtagCommandHandler(IHashtagRepository hashtagRepository, IUnitOfWork unitOfWork)
        {
            _hashtagRepository = hashtagRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(DeleteHashtagCommand command, CancellationToken cancellationToken)
        {
            _ = await _hashtagRepository.GetHashtagAsync(command.Id) ?? throw new NotFoundException("Hashtag doesn't exist");

            await _hashtagRepository.DeleteHashtagAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
