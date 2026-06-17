using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Api.Exceptions;

public sealed class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;
    private readonly IWebHostEnvironment _environment;

    public GlobalExceptionHandler(
        ILogger<GlobalExceptionHandler> logger,
        IWebHostEnvironment environment)
    {
        _logger = logger;
        _environment = environment;
    }

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        _logger.LogError(
            exception,
            "Unhandled exception. TraceId: {TraceId}",
            httpContext.TraceIdentifier);

        var (statusCode, title) = exception switch
        {
            ValidationException =>
                (StatusCodes.Status400BadRequest, exception.Message),

            NotFoundException =>
                (StatusCodes.Status404NotFound, exception.Message),

            UnauthorizedException =>
                (StatusCodes.Status401Unauthorized, exception.Message),

            ForbiddenException =>
                (StatusCodes.Status403Forbidden, exception.Message),

            ConflictException =>
                (StatusCodes.Status409Conflict, exception.Message),

            _ =>
                (StatusCodes.Status500InternalServerError,
                 "An unexpected error occurred.")
        };

        var problemDetails = new ProblemDetails
        {
            Status = statusCode,
            Title = title,
            Instance = httpContext.Request.Path
        };

        problemDetails.Extensions["traceId"] =
            httpContext.TraceIdentifier;

        if (_environment.IsDevelopment())
        {
            problemDetails.Extensions["exception"] =
                exception.ToString();
        }

        httpContext.Response.StatusCode = statusCode;

        await httpContext.Response.WriteAsJsonAsync(
            problemDetails,
            cancellationToken);

        return true;
    }
}