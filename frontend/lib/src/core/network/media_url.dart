import '../config/app_config.dart';

String resolveMediaUrl(String? value) {
  final url = value?.trim() ?? '';

  if (url.isEmpty) {
    return '';
  }

  final uri = Uri.tryParse(url);

  if (uri != null && uri.hasScheme) {
    return url;
  }

  final base = Uri.parse(AppConfig.apiBaseUrl);
  final normalizedPath = url.startsWith('/') ? url : '/$url';

  return base.replace(path: normalizedPath).toString();
}
