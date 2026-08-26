using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
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
        private readonly ILogger<PayPalService> _logger;
        public PayPalService(IConfiguration config, HttpClient httpClient, ILogger<PayPalService> logger)
        {
            _config = config;
            _http = httpClient;
            _logger = logger;
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
            _logger.LogDebug(
                "PayPal capture response: {Response}",
                json);

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

        public async Task<PayPalOrderDto> CreateOrderAsync(decimal amount, decimal platformFee, string sellerMerchantId)
        {
            if (string.IsNullOrWhiteSpace(
        sellerMerchantId))
            {
                throw new ArgumentException(
                    "Seller merchant ID is required.",
                    nameof(sellerMerchantId));
            }

            var token =
                await GetAccessTokenAsync();

            var currency =
                _config["PayPal:Currency"]
                ?? "USD";

            var request = new
            {
                intent = "CAPTURE",

                purchase_units = new[]
                {
            new
            {
                payee = new
                {
                    merchant_id =
                        sellerMerchantId
                },

                amount = new
                {
                    currency_code =
                        currency,

                    value =
                        amount.ToString(
                            "F2",
                            CultureInfo.InvariantCulture)
                },

                payment_instruction =
                    new
                    {
                        disbursement_mode =
                            "INSTANT",

                        platform_fees =
                            new[]
                            {
                                new
                                {
                                    amount =
                                        new
                                        {
                                            currency_code =
                                                currency,

                                            value =
                                                platformFee.ToString(
                                                    "F2",
                                                    CultureInfo.InvariantCulture)
                                        }
                                }
                            }
                    }
            }
        },

                application_context = new
                {
                    return_url =
                        "https://vidivideo.local/paypal/success",

                    cancel_url =
                        "https://vidivideo.local/paypal/cancel",

                    user_action =
                        "PAY_NOW"
                }
            };

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    token);

            // Required/recommended for partner attribution.
            var bnCode =
                _config[
                    "PayPal:PartnerAttributionId"];

            _http.DefaultRequestHeaders.Remove(
                "PayPal-Partner-Attribution-Id");

            if (!string.IsNullOrWhiteSpace(
                bnCode))
            {
                _http.DefaultRequestHeaders.Add(
                    "PayPal-Partner-Attribution-Id",
                    bnCode);
            }

            var response =
                await _http.PostAsJsonAsync(
                    $"{_config["PayPal:BaseUrl"]}" +
                    "/v2/checkout/orders",
                    request);

            var json =
                await response.Content
                    .ReadAsStringAsync();

            _logger.LogDebug(
                "PayPal create order response: {Response}",
                json);

            response.EnsureSuccessStatusCode();

            using var document =
                JsonDocument.Parse(json);

            var root =
                document.RootElement;

            var orderId =
                root.GetProperty("id")
                    .GetString()
                ?? throw new InvalidOperationException(
                    "PayPal did not return an order ID.");

            var approvalUrl =
                root.GetProperty("links")
                    .EnumerateArray()
                    .First(link =>
                        link.GetProperty("rel")
                            .GetString()
                        == "approve")
                    .GetProperty("href")
                    .GetString()
                ?? throw new InvalidOperationException(
                    "PayPal did not return an approval URL.");

            return new PayPalOrderDto(
                orderId,
                approvalUrl);

        }

        public async Task<PayPalOnboardingResult> CreateSellerOnboardingAsync(Guid userId, string email)
        {
            var token = await GetAccessTokenAsync();

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    token);

            var bnCode =
                _config[
                    "PayPal:PartnerAttributionId"];

            if (string.IsNullOrWhiteSpace(bnCode))
                throw new InvalidOperationException(
                    "PayPal Partner Attribution ID is missing.");

            _http.DefaultRequestHeaders.Remove(
                "PayPal-Partner-Attribution-Id");

            _http.DefaultRequestHeaders.Add(
                "PayPal-Partner-Attribution-Id",
                bnCode);

            var request = new
            {
                tracking_id = userId.ToString(),

                email,

                operations = new[]
                {
                    new
                    {
                        operation = "API_INTEGRATION",
                        api_integration_preference =
                            new
                            {
                                rest_api_integration =
                                    new
                                    {
                                        integration_method =
                                            "PAYPAL",

                                        integration_type =
                                            "THIRD_PARTY",

                                        third_party_details =
                                            new
                                            {
                                                features =
                                                    new[]
                                                    {
                                                        "PAYMENT",
                                                        "REFUND",
                                                        "PARTNER_FEE"
                                                    }
                                            }
                                    }
                            }
                    }
                },

                products = new[]
                {
                    "EXPRESS_CHECKOUT"
                },

                legal_consents = new[]
                {
                    new
                    {
                        type =
                            "SHARE_DATA_CONSENT",
                        granted = true
                    }
                },

                partner_config_override =
                    new
                    {
                        return_url =
                            "https://vidivideo.local/paypal/onboarding-success",

                        return_url_description =
                            "Return to VidiVideo"
                    }
            };

            var partnerMerchantId =
                _config[
                    "PayPal:PartnerMerchantId"];

            if (string.IsNullOrWhiteSpace(
                partnerMerchantId))
            {
                throw new InvalidOperationException(
                    "PayPal partner merchant ID is missing.");
            }

            var response =
                await _http.PostAsJsonAsync(
                    $"{_config["PayPal:BaseUrl"]}" +
                    $"/v2/customer/partner-referrals",
                    request);

            var json =
                await response.Content
                    .ReadAsStringAsync();

            _logger.LogDebug(
                "PayPal partner referral response: {Response}",
                json);

            response.EnsureSuccessStatusCode();

            using var document =
                JsonDocument.Parse(json);

            var actionUrl =
                document.RootElement
                    .GetProperty("links")
                    .EnumerateArray()
                    .First(link =>
                        link.GetProperty("rel")
                            .GetString()
                        == "action_url")
                    .GetProperty("href")
                    .GetString();

            if (string.IsNullOrWhiteSpace(
                actionUrl))
            {
                throw new InvalidOperationException(
                    "PayPal did not return an onboarding URL.");
            }

            return new PayPalOnboardingResult(
                actionUrl);
        }

        public async Task<PayPalMerchantStatus?> GetMerchantStatusByTrackingIdAsync(Guid userId)
        {
            var token =
        await GetAccessTokenAsync();

            var partnerMerchantId =
                _config["PayPal:PartnerMerchantId"];

            var bnCode =
                _config["PayPal:PartnerAttributionId"];

            if (string.IsNullOrWhiteSpace(
                partnerMerchantId))
            {
                throw new InvalidOperationException(
                    "PayPal partner merchant ID is missing.");
            }

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    token);

            _http.DefaultRequestHeaders.Remove(
                "PayPal-Partner-Attribution-Id");

            if (!string.IsNullOrWhiteSpace(bnCode))
            {
                _http.DefaultRequestHeaders.Add(
                    "PayPal-Partner-Attribution-Id",
                    bnCode);
            }

            var trackingId =
                Uri.EscapeDataString(
                    userId.ToString());

            var lookupUrl =
                $"{_config["PayPal:BaseUrl"]}" +
                $"/v1/customer/partners/" +
                $"{partnerMerchantId}/merchant-integrations" +
                $"?tracking_id={trackingId}";

            var lookupResponse =
                await _http.GetAsync(lookupUrl);

            var lookupJson =
                await lookupResponse.Content
                    .ReadAsStringAsync();

            _logger.LogDebug(
                "PayPal merchant lookup response: {Response}",
                lookupJson);

            if (lookupResponse.StatusCode ==
                System.Net.HttpStatusCode.NotFound)
            {
                return null;
            }

            lookupResponse.EnsureSuccessStatusCode();

            using var lookupDocument =
                JsonDocument.Parse(lookupJson);

            var lookupRoot =
                lookupDocument.RootElement;

            if (!lookupRoot.TryGetProperty(
                    "merchant_id",
                    out var merchantIdElement))
            {
                return null;
            }

            var merchantId =
                merchantIdElement.GetString();

            if (string.IsNullOrWhiteSpace(
                merchantId))
            {
                return null;
            }

            var detailsUrl =
                $"{_config["PayPal:BaseUrl"]}" +
                $"/v1/customer/partners/" +
                $"{partnerMerchantId}/merchant-integrations/" +
                $"{Uri.EscapeDataString(merchantId)}";

            var detailsResponse =
                await _http.GetAsync(detailsUrl);

            var detailsJson =
                await detailsResponse.Content
                    .ReadAsStringAsync();

            _logger.LogDebug(
                "PayPal merchant details response: {Response}",
                detailsJson);

            detailsResponse.EnsureSuccessStatusCode();

            using var detailsDocument =
                JsonDocument.Parse(detailsJson);

            var detailsRoot =
                detailsDocument.RootElement;

            var paymentsReceivable =
                detailsRoot.TryGetProperty(
                    "payments_receivable",
                    out var paymentsElement)
                && paymentsElement.ValueKind ==
                    JsonValueKind.True;

            var primaryEmailConfirmed =
                detailsRoot.TryGetProperty(
                    "primary_email_confirmed",
                    out var emailElement)
                && emailElement.ValueKind ==
                    JsonValueKind.True;

            return new PayPalMerchantStatus(
                merchantId,
                paymentsReceivable,
                primaryEmailConfirmed);
        }

        public async Task<PayPalRefundResult> RefundAsync(string captureId, decimal amount, string currency, string sellerMerchantId)
        {
            if (string.IsNullOrWhiteSpace(sellerMerchantId))
                throw new ArgumentException("Seller merchant ID is required", nameof(sellerMerchantId));

            var token = await GetAccessTokenAsync();

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    token);

            var bnCode =
                _config["PayPal:PartnerAttributionId"];

            _http.DefaultRequestHeaders.Remove(
                "PayPal-Partner-Attribution-Id");

            if (!string.IsNullOrWhiteSpace(bnCode))
            {
                _http.DefaultRequestHeaders.Add(
                    "PayPal-Partner-Attribution-Id",
                    bnCode);
            }

            var authAssertion = CreatePayPalAuthAssertion(sellerMerchantId);

            _http.DefaultRequestHeaders.Remove(
                "PayPal-Auth-Assertion");

            _http.DefaultRequestHeaders.Add(
                "PayPal-Auth-Assertion",
                authAssertion);

            _http.DefaultRequestHeaders.Remove(
                "PayPal-Request-Id");

            _http.DefaultRequestHeaders.Add(
                "PayPal-Request-Id",
                Guid.NewGuid().ToString());


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

            _logger.LogDebug(
                "PayPal refund response: {Response}",
                json);

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

        private string CreatePayPalAuthAssertion(string sellerMerchantId)
        {
            var clientId =
                _config["PayPal:ClientId"];

            if (string.IsNullOrWhiteSpace(clientId))
            {
                throw new InvalidOperationException(
                    "PayPal Client ID is missing.");
            }

            var header = new
            {
                alg = "none"
            };

            var payload = new
            {
                iss = clientId,
                payer_id = sellerMerchantId
            };

            var encodedHeader =
                Base64UrlEncode(
                    JsonSerializer.Serialize(
                        header));

            var encodedPayload =
                Base64UrlEncode(
                    JsonSerializer.Serialize(
                        payload));

            // Unsigned JWT intentionally ends with "."
            return $"{encodedHeader}.{encodedPayload}.";
        }

        private static string Base64UrlEncode(string value)
        {
            return Convert
                .ToBase64String(
                    Encoding.UTF8.GetBytes(value))
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');
        }
    }
}
