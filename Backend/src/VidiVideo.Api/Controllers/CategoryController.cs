using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Categories;
using VidiVideo.Application.Common;

namespace VidiVideo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CategoryController : ControllerBase
    {
        private readonly ICommandHandler<CreateCategoryCommand, Guid> _createHandler;
        private readonly ICommandHandler<DeleteCategoryCommand, bool> _deleteHandler;
        private readonly ICommandHandler<UpdateCategoryCommand, CategoryDTO> _updateHandler;
        private readonly IQueryHandler<GetCategoryByIdQuery, CategoryDTO> _getByIdHandler;
        private readonly IQueryHandler<GetCategoriesQuery, List<CategoryDTO>> _getCategoriesHandler;

        public CategoryController(ICommandHandler<CreateCategoryCommand, Guid> createHandler, ICommandHandler<DeleteCategoryCommand, bool> deleteHandler, ICommandHandler<UpdateCategoryCommand, CategoryDTO> updateHandler, IQueryHandler<GetCategoryByIdQuery, CategoryDTO> getByIdHandler, IQueryHandler<GetCategoriesQuery, List<CategoryDTO>> getCategoriesHandler)
        {
            _createHandler = createHandler;
            _deleteHandler = deleteHandler;
            _updateHandler = updateHandler;
            _getByIdHandler = getByIdHandler;
            _getCategoriesHandler = getCategoriesHandler;
        }

        [HttpPost("create")]
        public async Task<IActionResult> Create([FromBody] CreateCategoryRequest request, CancellationToken cancellationToken)
        {
            var command = new CreateCategoryCommand(request.categoryName);

            var categoryId = await _createHandler.HandleAsync(command, cancellationToken);

            return Ok(categoryId);
        }

        [HttpPatch("update")]
        public async Task<IActionResult> Update([FromBody] UpdateCategoryRequest request, CancellationToken cancellationToken)
        {
            var command = new UpdateCategoryCommand(request.Id, request.Name);

            var category = await _updateHandler.HandleAsync(command, cancellationToken);

            return Ok(category);
        }

        [HttpDelete("{categoryId:guid}")]
        public async Task<IActionResult> DeleteCountry(Guid categoryId, CancellationToken cancellationToken)
        {
            var command = new DeleteCategoryCommand(categoryId);

            var result = await _deleteHandler.HandleAsync(command, cancellationToken);

            return Ok(result);
        }

        [HttpGet("{Id:Guid}")]
        public async Task<IActionResult> GetCountry(Guid Id, CancellationToken cancellationToken)
        {
            var query = new GetCategoryByIdQuery(Id);

            var country = await _getByIdHandler.HandleAsync(query, cancellationToken);

            return Ok(country);
        }

        [HttpGet("getall")]
        public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
        {
            var result = await _getCategoriesHandler.HandleAsync(new GetCategoriesQuery(), cancellationToken);

            return Ok(result);
        }

    }
}
