using Microsoft.AspNetCore.Mvc;

namespace VidiVideo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { status = "Healthy", service = "VidiVideo.Api", timestampUtc = DateTime.UtcNow });
    }
}
