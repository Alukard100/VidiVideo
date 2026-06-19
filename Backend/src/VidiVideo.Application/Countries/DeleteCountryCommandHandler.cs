using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Application.Countries
{
    public sealed class DeleteCountryCommandHandler : ICommandHandler<DeleteCountryCommand, bool>
    {
        private readonly ICountryRepository _countryRepository;
        private readonly IUnitOfWork _unitOfWork;

        public DeleteCountryCommandHandler(ICountryRepository countryRepository, IUnitOfWork unitOfWork)
        {
            _countryRepository = countryRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> HandleAsync(DeleteCountryCommand command, CancellationToken cancellationToken)
        {
            _ = await _countryRepository.GetByIdAsync(command.Id) ?? throw new NotFoundException("Country doesn't exist");

            await _countryRepository.DeleteAsync(command.Id);

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
}
