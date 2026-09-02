using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Formats.Webp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Abstractions.DTOs;
using VidiVideo.Application.Exceptions;
using VidiVideo.Domain.Enums;

namespace VidiVideo.Infrastructure.Media;
public sealed class ImageProcessorService : IImageProcessor
{
    private const int MaxImageSize = 5 * 1024 * 1024;
    private static readonly HashSet<string> AllowedExtensions = [".jpg", ".png", ".jpeg", ".webp"];
    public async Task<ProcessedImage> ProcessAsync(Stream stream, string fileName, ImagePurpose imagePurpose, CancellationToken cancellationToken = default)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        if (!AllowedExtensions.Contains(extension)) throw new ValidationException("Invalid image format.");

        var options = GetOptions(imagePurpose);

        await using var input = new MemoryStream();

        await CopyWithSizeLimitAsync(stream, input, MaxImageSize, cancellationToken);

        input.Position = 0;

        var info = await Image.IdentifyAsync(input, cancellationToken);

        if (info is null) throw new ValidationException("Invalid image.");

        if (info.Width > options.MaxWidth || info.Height > options.MaxHeight) throw new ValidationException($"Image dimensions must not exceed {options.MaxWidth} x {options.MaxHeight}.");

        input.Position = 0;

        using var image = await Image.LoadAsync<Rgba32>(input, cancellationToken);

        image.Mutate(ctx =>
        {
            ctx.AutoOrient();
            if (options.CropToSquare)
            {
                ctx.Resize(new ResizeOptions
                {
                    Size = new Size(options.OutputMaxWidth, options.OutputMaxHeight),
                    Mode = ResizeMode.Crop,
                    Position = AnchorPositionMode.Center
                });
            }
            else
            {
                ctx.Resize(new ResizeOptions
                {
                    Size = new Size(options.OutputMaxWidth, options.OutputMaxHeight),
                    Mode = ResizeMode.Max
                });
            }
        });

        image.Metadata.ExifProfile = null;
        image.Metadata.IccProfile = null;
        image.Metadata.XmpProfile = null;

        await using var output = new MemoryStream();

        var outputExtension = extension;
        string contentType;

        switch (extension)
        {
            case ".jpg":
            case ".jpeg":
                await image.SaveAsync(output, new JpegEncoder { Quality = options.Quality }, cancellationToken);
                outputExtension = ".jpg";
                contentType = "image/jpeg";
                break;

            case ".png":
                await image.SaveAsync(
                    output,
                    new PngEncoder(),
                    cancellationToken);

                outputExtension = ".png";
                contentType = "image/png";
                break;

            case ".webp":
                await image.SaveAsync(
                    output,
                    new WebpEncoder
                    {
                        Quality = options.Quality
                    },
                    cancellationToken);

                outputExtension = ".webp";
                contentType = "image/webp";
                break;

            default:
                throw new ValidationException(
                    "Unsupported image format.");
        }

        return new ProcessedImage(
            output.ToArray(),
            outputExtension,
            contentType);


    }

    private static ImageProcessingOptions GetOptions(ImagePurpose purpose)
    {
        return purpose switch
        {
            ImagePurpose.Thumbnail => new ImageProcessingOptions(8192, 8192, 1080, 1920),

            ImagePurpose.ProfilePicture => new ImageProcessingOptions(8192, 8192, 512, 512, 85, true),

            ImagePurpose.Emoji => new ImageProcessingOptions(4096, 4096, 128, 128, 80, false),

            _ => throw new ValidationException("Out of max size range")
        };
    }

    private static async Task CopyWithSizeLimitAsync(
        Stream source,
        Stream destination,
        int maxBytes,
        CancellationToken cancellationToken)
    {
        var buffer = new byte[81920];
        var totalBytes = 0;

        while (true)
        {
            var read = await source.ReadAsync(
                buffer.AsMemory(0, buffer.Length),
                cancellationToken);

            if (read == 0)
                break;

            totalBytes += read;

            if (totalBytes > maxBytes)
                throw new ValidationException(
                    "Image is too large.");

            await destination.WriteAsync(
                buffer.AsMemory(0, read),
                cancellationToken);
        }
    }
}
