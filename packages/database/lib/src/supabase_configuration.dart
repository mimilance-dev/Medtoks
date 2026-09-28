class SupabaseConfiguration {
  const SupabaseConfiguration({
    required this.url,
    required this.publishableKey,
  });

  final String url;
  final String publishableKey;

  List<String> validate() {
    final issues = <String>[];
    final uri = Uri.tryParse(url);
    final isLocal = uri?.host == 'localhost' || uri?.host == '127.0.0.1';
    if (uri == null ||
        !uri.hasAuthority ||
        !(uri.scheme == 'https' || (isLocal && uri.scheme == 'http'))) {
      issues.add('Supabase URL must be HTTPS (HTTP is allowed for localhost).');
    }
    if (publishableKey.isEmpty) {
      issues.add('A Supabase publishable key is required.');
    }
    return List.unmodifiable(issues);
  }
}
