using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Entities;

namespace VidiVideo.Application.Hashtags
{
    public sealed class CreateHashtagCommandHandler : ICommandHandler<CreateHashtagCommand, Guid>
    {
        private readonly IHashtagRepository _repository;
        private readonly IUnitOfWork _unitOfWork;

        public CreateHashtagCommandHandler(IHashtagRepository repository, IUnitOfWork unitOfWork)
        {
            _repository = repository;
            _unitOfWork = unitOfWork;
        }
        public async Task<Guid> HandleAsync(CreateHashtagCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.Name))
                throw new ValidationException(
                    "Cant be empty");

            if (await _repository.ExistByNameAsync(command.Name))
                throw new ConflictException("Already exists");

            Hashtag hashtag = new(command.Name);

            await _repository.CreateHashtagAsync(hashtag);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return hashtag.Id;


        }
    }
}
