using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.ChannelEmojis;
using VidiVideo.Application.Exceptions;

namespace VidiVideo.Infrastructure.AccessValidators
{
    public sealed class ChannelEmojiUsageValidator : IChannelEmojiUsageValidator
    {
        private readonly IChannelEmojiRepository _emojiRepository;
        private readonly IPaymentRepository _paymentRepository;

        public ChannelEmojiUsageValidator(IChannelEmojiRepository emojiRepository, IPaymentRepository paymentRepository)
        {
            _emojiRepository = emojiRepository;
            _paymentRepository = paymentRepository;
        }

        public async Task ValidateAsync(Guid userId, string text, CancellationToken cancellationToken)
        {
            var codes = EmojiParser.ExtractCodes(text);

            if (codes.Count == 0) return;

            var emojis = await _emojiRepository.GetByCodesWithoutDeletedAsync(codes, cancellationToken);

            var foundCodes = emojis.Select(x => x.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);

            var missingCodes = codes.Where(code => !foundCodes.Contains(code)).ToArray();

            if (missingCodes.Length > 0) throw new NotFoundException($"Emoji/s not found: {string.Join(", ", missingCodes.Select(x => $":{x}:"))}");

            var subscribedCreatorIds = await _paymentRepository.GetActiveSubscribedCreatorIdsAsync(userId);

            foreach (var emoji in emojis)
            {
                var ownsEmoji = emoji.CreatorId == userId;

                var subscribedToCreator = subscribedCreatorIds.Contains(emoji.CreatorId);

                if (!ownsEmoji && !subscribedToCreator) throw new ForbiddenException($"You need an active subscription to use :{emoji.Code}:.");
            }
        }
    }
}
