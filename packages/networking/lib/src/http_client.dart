import 'package:dio/dio.dart';

Dio createHttpClient({required String baseUrl}) {
  final uri = Uri.tryParse(baseUrl);
  final isLocal = uri?.host == 'localhost' || uri?.host == '127.0.0.1';
  if (baseUrl.isNotEmpty &&
      (uri == null ||
          !uri.hasAuthority ||
          !(uri.scheme == 'https' || (isLocal && uri.scheme == 'http')))) {
    throw ArgumentError.value(
      baseUrl,
      'baseUrl',
      'Must be HTTPS (HTTP is allowed for localhost).',
    );
  }
  final client = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.putIfAbsent('Accept', () => 'application/json');
        handler.next(options);
      },
    ),
  );
  return client;
}
