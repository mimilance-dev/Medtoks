import 'package:medtoks_networking/medtoks_networking.dart';
import 'package:test/test.dart';

void main() {
  test('configures a shared client with the supplied base URL', () {
    final client = createHttpClient(baseUrl: 'https://api.example.test');
    expect(client.options.baseUrl, 'https://api.example.test');
    expect(client.interceptors, hasLength(1));
  });
}
