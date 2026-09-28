import 'package:medtoks_core/medtoks_core.dart';
import 'package:test/test.dart';

void main() {
  test('accepts an unconfigured development environment', () {
    const config = AppEnvironmentConfig(environment: 'development');
    expect(config.validate(), isEmpty);
    expect(config.parsedEnvironment, MedtoksEnvironment.development);
  });

  test('reports invalid environment and malformed endpoint', () {
    const config = AppEnvironmentConfig(
      environment: 'preview',
      apiBaseUrl: 'http://api.example.com',
    );
    expect(config.validate(), hasLength(2));
  });
}
