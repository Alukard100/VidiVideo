using Microsoft.Extensions.Configuration;
using System.Globalization;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using VidiVideo.Application.Abstractions;

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
        public async Task<bool> CaptureOrderAsync(string orderId)
        {
            var token = await GetAccessTokenAsync();

            _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);

            var response = await _http.PostAsJsonAsync(
                $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders/{orderId}/capture",
                new { });

            var content = await response.Content.ReadAsStringAsync();
            Console.WriteLine(content);

            response.EnsureSuccessStatusCode();

            return response.IsSuccessStatusCode;
        }

        public async Task<string> CreateOrderAsync(decimal amount)
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
                }
            };

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);

            var response = await _http.PostAsJsonAsync(
                $"{_config["PayPal:BaseUrl"]}/v2/checkout/orders",
                request);

            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            return JsonDocument.Parse(json)
                .RootElement.GetProperty("id").GetString()!;

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
