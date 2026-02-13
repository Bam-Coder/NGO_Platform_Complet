import 'constants.dart';

String? normalizeMediaUrl(String? input) {
  if (input == null || input.isEmpty) return input;

  // Local file path (offline cache / camera): keep as-is.
  if (!input.startsWith('http://') &&
      !input.startsWith('https://') &&
      !input.startsWith('/uploads/')) {
    return input;
  }

  final Uri? base = Uri.tryParse(ApiConstants.baseUrl);
  if (base == null) return input;

  if (input.startsWith('/uploads/')) {
    return '${base.scheme}://${base.authority}$input';
  }

  final Uri? raw = Uri.tryParse(input);
  if (raw == null) return input;

  const localLikeHosts = {
    'localhost',
    '127.0.0.1',
    '10.0.2.2',
    '10.0.3.2',
  };

  final bool isUploads = raw.path.startsWith('/uploads/');
  final bool shouldRewriteHost = localLikeHosts.contains(raw.host) && isUploads;

  if (!shouldRewriteHost) return input;

  final Uri rewritten = raw.replace(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
  );

  return rewritten.toString();
}

List<String> normalizeMediaUrls(List<dynamic>? values) {
  if (values == null) return const [];

  return values
      .map((v) => normalizeMediaUrl(v?.toString()))
      .whereType<String>()
      .where((v) => v.isNotEmpty)
      .toList(growable: false);
}
