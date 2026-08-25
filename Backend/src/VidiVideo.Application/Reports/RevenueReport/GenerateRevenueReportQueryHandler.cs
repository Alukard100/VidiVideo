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

            var totalRevenue = await _paymentRepository.TotalRevenueAsync(query.From, cancellationToken);
            var totalPayments = await _paymentRepository.TotalPaymentsAsync(query.From, cancellationToken);
            var totalActiveSubs = await _paymentRepository.TotalActiveSubsAsync(cancellationToken);
            var topCreators = await _paymentRepository.TopCreatorsAsync(query.From);


            var rows = topCreators.Select(c => new RevenueAnalyticsRow(
                    c.Creator,
                    c.ActiveSubscribers,
                    c.Revenue,
                    c.CompletedPayments
                )).ToList();

            var dto = new RevenueAnalyticsDto(query.From,
                totalRevenue,
                totalPayments,
                totalActiveSubs,
                rows);

            return _revenueReportGenerator.Generate(dto);
        }
    }
}
