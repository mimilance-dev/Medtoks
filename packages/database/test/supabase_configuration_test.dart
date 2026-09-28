import 'package:medtoks_database/medtoks_database.dart';
import 'package:test/test.dart';

void main() {
  test('requires an HTTPS endpoint and a publishable key', () {
    const config = SupabaseConfiguration(
      url: 'http://supabase.example.test',
      publishableKey: '',
    );
    expect(config.validate(), hasLength(2));
  });

  test('accepts a local Supabase endpoint with a publishable key', () {
    const config = SupabaseConfiguration(
      url: 'http://localhost:54321',
      publishableKey: 'local-publishable-key',
    );
    expect(config.validate(), isEmpty);
  });
}
