using VidiVideo.Application.Common;

namespace VidiVideo.Application.Hashtags
{
    public sealed record CreateHashtagCommand(string Name) : ICommand<Guid>;
}
