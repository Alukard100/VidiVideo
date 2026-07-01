using System.Text.RegularExpressions;

namespace VidiVideo.Application.Hashtags
{
    public static class HashtagParser
    {
        public static List<string> Extract(string caption)
        {
            return Regex.Matches(
                    caption,
                    @"#(\w+)")
                .Select(m => m.Groups[1].Value.ToLowerInvariant())
                .Distinct()
                .ToList();
        }
    }
}
