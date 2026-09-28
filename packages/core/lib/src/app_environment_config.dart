enum MedtoksEnvironment { development, staging, production }

class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.environment,
    this.supabaseUrl = '',
    this.supabasePublishableKey = '',
    this.apiBaseUrl = '',
    this.mentorDashboardEnabled = false,
  });

  factory AppEnvironmentConfig.fromEnvironment() {
    return AppEnvironmentConfig(
      environment: const String.fromEnvironment(
        'MEDTOKS_ENV',
        defaultValue: 'development',
      ),
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: const String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      mentorDashboardEnabled: const bool.fromEnvironment(
        'FEATURE_MENTOR_DASHBOARD',
      ),
    );
  }

  final String environment;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String apiBaseUrl;
  final bool mentorDashboardEnabled;

  MedtoksEnvironment? get parsedEnvironment {
    for (final value in MedtoksEnvironment.values) {
      if (value.name == environment) return value;
    }
    return null;
  }

  List<String> validate({bool requireSupabase = false}) {
    final issues = <String>[];
    if (parsedEnvironment == null) {
      issues.add('MEDTOKS_ENV must be development, staging, or production.');
    }
    _validateUrl('SUPABASE_URL', supabaseUrl, issues);
    _validateUrl('API_BASE_URL', apiBaseUrl, issues);
    if (supabaseUrl.isNotEmpty && supabasePublishableKey.isEmpty) {
      issues.add('SUPABASE_PUBLISHABLE_KEY is required when Supabase is configured.');
    }
    if (requireSupabase &&
        (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty)) {
      issues.add('Supabase URL and publishable key are required.');
    }
    return List.unmodifiable(issues);
  }

  void _validateUrl(String name, String value, List<String> issues) {
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value);
    final isLocal = uri?.host == 'localhost' || uri?.host == '127.0.0.1';
    if (uri == null ||
        !uri.hasAuthority ||
        !(uri.scheme == 'https' || (isLocal && uri.scheme == 'http'))) {
      issues.add('$name must be an HTTPS URL (HTTP is allowed for localhost).');
    }
  }
}
