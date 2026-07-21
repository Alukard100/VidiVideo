using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.Repositories;
using VidiVideo.Application.Common;

namespace VidiVideo.Application.Reports.RevenueReport
{
    public sealed class GenerateRevenueReportQueryHandler : IQueryHandler<GenerateRevenueReportQuery, byte[]>
    {
        private readonly IRevenueReportGenerator _revenueReportGenerator;
        private readonly IPaymentRepository _paymentRepository;
        public GenerateRevenueReportQueryHandler(IRevenueReportGenerator revenueReportGenerator, IPaymentRepository paymentRepository)
        {
            _revenueReportGenerator = revenueReportGenerator;
            _paymentRepository = paymentRepository;
        }

        public async Task<byte[]> HandleAsync(GenerateRevenueReportQuery query, CancellationToken cancellationToken)
        {

            var totalRevenue = _paymentRepository.TotalRevenueAsync(query.From);
            var totalPayments = _paymentRepository.TotalPaymentsAsync(query.From);
            var totalActiveSubs = _paymentRepository.TotalActiveSubsAsync();
            var topCreators = _paymentRepository.TopCreatorsAsync(query.From);

            await Task.WhenAll(
                totalRevenue,
                totalPayments,
                totalActiveSubs,
                topCreators);

            var rows = topCreators.Result.Select(c => new RevenueAnalyticsRow(
                    c.Creator,
                    c.ActiveSubscribers,
                    c.Revenue,
                    c.CompletedPayments
                )).ToList();

            var dto = new RevenueAnalyticsDto(query.From,
                totalRevenue.Result,
                totalPayments.Result,
                totalActiveSubs.Result,
                rows);

            return _revenueReportGenerator.Generate(dto);
        }
    }
}
