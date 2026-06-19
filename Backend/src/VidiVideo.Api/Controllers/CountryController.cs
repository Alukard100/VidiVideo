using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Common;
using VidiVideo.Application.Countries;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CountryController : ControllerBase
{
    private readonly ICommandHandler<CreateCountryCommand, Guid> _createHandler;
    private readonly IQueryHandler<GetCountriesQuery, List<CountryDto>> _getCountriesHandler;
    private readonly IQueryHandler<GetCountryByIdQuery, CountryDto> _getCountryByIdHandler;
    private readonly ICommandHandler<DeleteCountryCommand, bool> _deleteHandler;
    private readonly ICommandHandler<UpdateCountryCommand, CountryDto> _updateCountryHandler;
    public CountryController(ICommandHandler<CreateCountryCommand, Guid> createHandler, IQueryHandler<GetCountriesQuery, List<CountryDto>> getCountriesHandler, IQueryHandler<GetCountryByIdQuery, CountryDto> getCountryByIdHandler, ICommandHandler<DeleteCountryCommand, bool> deleteHandler, ICommandHandler<UpdateCountryCommand, CountryDto> updateCountryHandler)
    {
        _createHandler = createHandler;
        _getCountriesHandler = getCountriesHandler;
        _getCountryByIdHandler = getCountryByIdHandler;
        _deleteHandler = deleteHandler;
        _updateCountryHandler = updateCountryHandler;
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CreateCountryRequest request, CancellationToken cancellationToken)
    {
        var command = new CreateCountryCommand(request.Name, request.Code);

        var countryId = await _createHandler.HandleAsync(command, cancellationToken);

        return Ok(countryId);
    }

    [HttpGet("getall")]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await _getCountriesHandler.HandleAsync(new GetCountriesQuery(), cancellationToken);

        return Ok(result);
    }

    [HttpGet("{Id:Guid}")]
    public async Task<IActionResult> GetCountry(Guid Id, CancellationToken cancellationToken)
    {
        var query = new GetCountryByIdQuery(Id);

        var country = await _getCountryByIdHandler.HandleAsync(query, cancellationToken);

        return Ok(country);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> DeleteCountry(Guid Id, CancellationToken cancellationToken)
    {
        var command = new DeleteCountryCommand(Id);

        var result = await _deleteHandler.HandleAsync(command, cancellationToken);

        return Ok(result);
    }

    [HttpPatch("update")]
    public async Task<IActionResult> Update([FromBody] UpdateCountryRequest request, CancellationToken cancellationToken)
    {
        var command = new UpdateCountryCommand(request.Id, request.Name, request.Code);

        var country = await _updateCountryHandler.HandleAsync(command, cancellationToken);

        return Ok(country);
    }
}
