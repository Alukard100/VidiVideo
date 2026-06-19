using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags
{
    public sealed record DeleteHashtagCommand(Guid Id) : ICommand<bool>;
}
