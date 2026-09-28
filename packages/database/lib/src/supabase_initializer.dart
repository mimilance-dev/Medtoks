import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_configuration.dart';

Future<SupabaseClient>? _initialization;

Future<SupabaseClient> initializeSupabase(SupabaseConfiguration config) {
  final issues = config.validate();
  if (issues.isNotEmpty) {
    throw ArgumentError.value(issues, 'config', 'Invalid Supabase configuration');
  }
  return _initialization ??= Supabase.initialize(
    url: config.url,
    anonKey: config.publishableKey,
  ).then((_) => Supabase.instance.client);
}
