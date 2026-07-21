using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using System.Globalization;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Reports.RevenueReport;

namespace VidiVideo.Infrastructure.Reports
{
    public sealed class RevenueReportGenerator : IRevenueReportGenerator
    {
        public byte[] Generate(RevenueAnalyticsDto dto)
        {
            var utcNow = DateTime.UtcNow;

            return Document.Create(container =>
            {
                container.Page(page =>
                {
                    var title = dto.From.HasValue ? $"VidiVideo Revenue Report ({dto.From.Value:dd.MM.yyyy} - {utcNow:dd.MM.yyyy})" : "VidiVideo Revenue Report";

                    page.Margin(30);

                    page.Header()
                        .Text(title)
                        .FontSize(24)
                        .Bold();

                    page.Content().Column(column =>
                    {
                        column.Item().Text($"Generated: {utcNow:dd.MM.yyyy HH:mm}");

                        column.Item().Text($"Total Revenue: {dto.TotalRevenue:N2} USD");

                        column.Item().Text($"Total Payments: {dto.TotalPayments}");

                        column.Item().Text($"Total Active subscribers: {dto.TotalActiveSubscriptions}");
                    });

                    page.Footer()
                    .AlignCenter()
                    .Text(x =>
                    {
                        x.Span("Page ");
                        x.CurrentPageNumber();
                        x.Span(" of ");
                        x.TotalPages();
                    });
                });
                container.Page(page =>
                {
                    var title = dto.From.HasValue ? $"Top Earning Creators from {dto.From.Value:dd.MM.yyyy} - {utcNow:dd.MM.yyyy}" : "Top Earning Creators";

                    page.Header()
                        .Text(title)
                        .FontSize(24)
                        .Bold();

                    page.Content().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(35);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                        });

                        table.Header(header =>
                        {
                            header.Cell().Element(HeaderCell).Text("No.");
                            header.Cell().Element(HeaderCell).Text("Creator");
                            header.Cell().Element(HeaderCell).AlignRight().Text("Revenue");
                            header.Cell().Element(HeaderCell).AlignRight().Text("Payments");
                            header.Cell().Element(HeaderCell).AlignRight().Text("Active subscribers");
                        });

                        var row = dto.Rows;

                        for (int i = 0; i < row.Count; i++)
                        {
                            table.Cell().Element(Cell).AlignRight().Text((i + 1).ToString());
                            table.Cell().Element(Cell).Text(row[i].Creator);
                            table.Cell().Element(Cell).AlignRight().Text(row[i].Revenue.ToString("C2", CultureInfo.GetCultureInfo("en-US")));
                            table.Cell().Element(Cell).AlignRight().Text(row[i].CompletedPayments.ToString("N0"));
                            table.Cell().Element(Cell).AlignRight().Text(row[i].ActiveSubscribers.ToString("N0"));

                        }
                    });

                    page.Footer()
                    .AlignCenter()
                    .Text(x =>
                    {
                        x.Span("Page ");
                        x.CurrentPageNumber();
                        x.Span(" of ");
                        x.TotalPages();
                    });
                });
            }).GeneratePdf();


        }

        private static IContainer HeaderCell(IContainer container)
        {
            return container
                .BorderBottom(1)
                .PaddingVertical(5)
                .Background("#EEEEEE")
                .PaddingHorizontal(4);
        }

        private static IContainer Cell(IContainer container)
        {
            return container
                .BorderBottom(1)
                .BorderColor("#DDDDDD")
                .PaddingVertical(4)
                .PaddingHorizontal(4);
        }
    }

}