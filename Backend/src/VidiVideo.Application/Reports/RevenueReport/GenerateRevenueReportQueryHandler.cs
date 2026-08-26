using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Reports.RevenueReport
{
    public sealed class GenerateRevenueReportQueryHandler : IQueryHandler<GenerateRevenueReportQuery, byte[]>
    {
        private readonly IRevenueReportGenerator _revenueReportGenerator;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IPaymentSettings _paymentSettings;
        public GenerateRevenueReportQueryHandler(IRevenueReportGenerator revenueReportGenerator, IPaymentRepository paymentRepository, IPaymentSettings paymentSettings)
        {
            _revenueReportGenerator = revenueReportGenerator;
            _paymentRepository = paymentRepository;
            _paymentSettings = paymentSettings;
        }

        public async Task<byte[]> HandleAsync(GenerateRevenueReportQuery query, CancellationToken cancellationToken)
        {

            var totalTransactionValue = await _paymentRepository.TotalRevenueAsync(query.From, cancellationToken);
            var totalPayments = await _paymentRepository.TotalPaymentsAsync(query.From, cancellationToken);
            var totalActiveSubs = await _paymentRepository.TotalActiveSubsAsync(cancellationToken);
            var topCreators = await _paymentRepository.TopCreatorsAsync(query.From);
            var totalRevenue = totalPayments * _paymentSettings.PlatformFee;

            var rows = topCreators.Select(c => new RevenueAnalyticsRow(
                    c.Creator,
                    c.ActiveSubscribers,
                    c.Revenue,
                    c.CompletedPayments
                )).ToList();

            var dto = new RevenueAnalyticsDto(query.From,
                totalTransactionValue,
                totalRevenue,
                totalPayments,
                totalActiveSubs,
                rows);

            return _revenueReportGenerator.Generate(dto);
        }
    }
}
