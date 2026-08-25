using Microsoft.Extensions.Configuration;
using System.Globalization;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using VidiVideo.Application.Abstractions;
using VidiVideo.Application.Payments.PayPal;

namespace VidiVideo.Infrastructure.Payments
{
    public sealed class PayPalService : IPayPalService
    {
        private readonly IConfiguration _config;
        private readonly HttpClient _http;
        public PayPalService(IConfiguration config, HttpClient httpClient)
        {
            _config = config;
            _http = httpClient;
        }
        public async Task<PayPalCaptureResult> CaptureOrderAsync(string orderId)
        {
            var token = await GetAccessTokenAsync();

            _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);

            var response = await _http.PostAsJsonAsync(
                $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders/{orderId}/capture",
                new { });

            var json = await response.Content.ReadAsStringAsync();
            Console.WriteLine(json);

            response.EnsureSuccessStatusCode();

            using var document = JsonDocument.Parse(json);

            var root = document.RootElement;

            var status = root.GetProperty("status").GetString();

            if (!string.Equals(status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
            {
                return new PayPalCaptureResult(false, null);
            }

            var captureId = root
                .GetProperty("purchase_units")[0]
                .GetProperty("payments")
                .GetProperty("captures")[0]
                .GetProperty("id")
                .GetString();

            if (string.IsNullOrWhiteSpace(captureId))
            {
                throw new InvalidOperationException("PayPal did not return a capture ID");
            }

            return new PayPalCaptureResult(true, captureId);

        }

        public async Task<PayPalOrderDto> CreateOrderAsync(decimal amount)
        {
            var token = await GetAccessTokenAsync();

            var request = new
            {
                intent = "CAPTURE",
                purchase_units = new[]
                {
                    new
                    {
                        amount = new
                        {
                            currency_code = _config["PayPal:Currency"],
                            value = amount.ToString("F2", CultureInfo.InvariantCulture)
                        }
                    }
                },
                application_context = new
                {
                    return_url = "https://vidivideo.local/paypal/success",
                    cancel_url = "https://vidivideo.local/paypal/cancel",
                    user_action = "PAY_NOW"
                }
            };

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);

            var response = await _http.PostAsJsonAsync(
                $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders",
                request);

            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();

            using var document = JsonDocument.Parse(json);

            var root = document.RootElement;

            var orderId = root.GetProperty("id").GetString() ?? throw new InvalidOperationException("PayPal did not return an order ID");

            var approvalUrl = root.GetProperty("links").EnumerateArray()
                .First(LinkedList =>
                    LinkedList.GetProperty("rel")
                    .GetString() == "approve")
                .GetProperty("href")
                .GetString()
            ?? throw new InvalidOperationException("PayPal did not return an approval URL.");

            return new PayPalOrderDto(orderId, approvalUrl);

        }

        public async Task<PayPalRefundResult> RefundAsync(string captureId, decimal amount, string currency)
        {
            var token = await GetAccessTokenAsync();

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    token);

            var request = new
            {
                amount = new
                {
                    value = amount.ToString(
                        "F2",
                        CultureInfo.InvariantCulture),
                    currency_code = currency
                }
            };

            var response =
                await _http.PostAsJsonAsync($"{_config["PayPal:BaseUrl"]}/v2/payments/captures/{captureId}/refund", request);

            var json = await response.Content.ReadAsStringAsync();

            Console.WriteLine(json);

            response.EnsureSuccessStatusCode();

            using var document =
                JsonDocument.Parse(json);

            var root =
                document.RootElement;

            var refundId =
                root.GetProperty("id")
                    .GetString()
                ?? throw new InvalidOperationException(
                    "PayPal did not return a refund ID.");

            var status =
                root.GetProperty("status")
                    .GetString()
                ?? "UNKNOWN";

            return new PayPalRefundResult(
                refundId,
                status);
        }

        private async Task<string> GetAccessTokenAsync()
        {
            var byteArray = Encoding.ASCII.GetBytes(
                $"{_config["PayPal:ClientId"]}:{_config["PayPal:Secret"]}");

            _http.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));

            var response = await _http.PostAsync(
                $"{_config["PayPal:BaseUrl"]}/v1/oauth2/token",
                new FormUrlEncodedContent(new[]
                {
                    new KeyValuePair<string, string>("grant_type", "client_credentials")
                }));

            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            return JsonDocument.Parse(json)
                .RootElement.GetProperty("access_token").GetString()!;
        }
    }
}
