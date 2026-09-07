using System.Text.RegularExpressions;

namespace VidiVideo.Application.ChannelEmojis;

public static partial class EmojiParser
{
    [GeneratedRegex(@":([A-Za-z0-9_]{1,32}):")]
    private static partial Regex EmojiRegex();

    public static IReadOnlyCollection<string> ExtractCodes(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return [];

        return EmojiRegex()
            .Matches(text)
            .Select(x => x.Groups[1].Value)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }
}
