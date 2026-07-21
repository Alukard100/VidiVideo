using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Reports.VideosReport;

namespace VidiVideo.Infrastructure.Reports
{
    public sealed class VideoAnalyticsReportGenerator : IVideoAnalyticsReportGenerator
    {
        public byte[] Generate(VideoAnalyticsReportDto dto)
        {
            var utcNow = DateTime.UtcNow;

            return Document.Create(container =>
            {
                container.Page(page =>
                {
                    var title = dto.From.HasValue ? $"VidiVideo Analytics Report ({dto.From.Value:dd.MM.yyyy} - {utcNow:dd.MM.yyyy})" : "VidiVideo Analytics Report";

                    page.Margin(30);

                    page.Header()
                        .Text(title)
                        .FontSize(24)
                        .Bold();

                    page.Content().Column(column =>
                    {
                        column.Item().Text($"Generated: {utcNow:dd.MM.yyyy HH:mm HH:mm}");

                        column.Item().Text($"Videos: {dto.TotalVideos}");

                        column.Item().Text($"Views: {dto.TotalViews}");

                        column.Item().Text($"Likes: {dto.TotalLikes}");

                        column.Item().Text($"Comments: {dto.TotalComments}");

                        column.Item().Text($"Published videos: {dto.PublishedVideos}");

                        column.Item().Text($"Public videos: {dto.PublicVideos}");

                        column.Item().Text($"Subscriber videos: {dto.SubscriberVideos}");
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
                    var title = dto.From.HasValue ? $"Top videos from {dto.From.Value:dd.MM.yy}" : $"Top Videos ({utcNow:dd.MM.yyyy HH:mm} UTC)";

                    page.Margin(30);

                    page.Header()
                        .Text($"Top Videos ({utcNow:dd.MM.yyyy HH:mm} UTC)")
                        .FontSize(22)
                        .Bold();

                    page.Content().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(35);
                            columns.RelativeColumn(3);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                        });

                        table.Header(header =>
                        {
                            header.Cell().Element(HeaderCell).Text("No.");
                            header.Cell().Element(HeaderCell).Text("Caption");
                            header.Cell().Element(HeaderCell).Text("Creator");
                            header.Cell().Element(HeaderCell).AlignRight().Text("Views");
                            header.Cell().Element(HeaderCell).AlignRight().Text("Likes");
                            header.Cell().Element(HeaderCell).AlignRight().Text("Comments");
                        });

                        var row = dto.Rows;

                        for (int i = 0; i < row.Count; i++)
                        {
                            table.Cell().Element(Cell).AlignRight().Text((i + 1).ToString());
                            table.Cell().Element(Cell).Text(Shorten(row[i].Caption, 30));
                            table.Cell().Element(Cell).Text(row[i].Creator);
                            table.Cell().Element(Cell).AlignRight().Text(row[i].Views.ToString("N0"));
                            table.Cell().Element(Cell).AlignRight().Text(row[i].Likes.ToString("N0"));
                            table.Cell().Element(Cell).AlignRight().Text(row[i].Comments.ToString("N0"));

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

        private static string Shorten(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return "";

            return text.Length <= maxLength ? text : text[..maxLength] + "...";
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
