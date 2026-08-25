using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using VidiVideo.Domain.Enums;
using VidiVideo.Infrastructure.Persistence;

namespace VidiVideo.Api.Middleware;

public sealed class ActiveUserMiddleware
{
    private readonly RequestDelegate _next;

    public ActiveUserMiddleware(
        RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(
        HttpContext context,
        VidiVideoDbContext db)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var idClaim =
                context.User.FindFirstValue(
                    ClaimTypes.NameIdentifier);

            if (Guid.TryParse(
                idClaim,
                out var userId))
            {
                var status =
                    await db.Users
                        .AsNoTracking()
                        .Where(u => u.Id == userId)
                        .Select(u => new
                        {
                            u.Status,
                            u.IsDeleted
                        })
                        .FirstOrDefaultAsync(
                            context.RequestAborted);

                if (status == null ||
                    status.IsDeleted ||
                    status.Status != UserStatus.Active)
                {
                    context.Response.StatusCode =
                        StatusCodes
                            .Status401Unauthorized;

                    await context.Response.WriteAsJsonAsync(
                        new
                        {
                            message =
                                "Account is not active."
                        },
                        context.RequestAborted);

                    return;
                }
            }
        }

        await _next(context);
    }
}