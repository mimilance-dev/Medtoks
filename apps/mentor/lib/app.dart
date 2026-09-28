import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medtoks_core/medtoks_core.dart';
import 'package:medtoks_database/medtoks_database.dart';
import 'package:medtoks_design_system/medtoks_design_system.dart';
import 'package:medtoks_networking/medtoks_networking.dart';

class MentorAppConfig {
  const MentorAppConfig(this.environment);

  factory MentorAppConfig.fromEnvironment() {
    return MentorAppConfig(AppEnvironmentConfig.fromEnvironment());
  }

  final AppEnvironmentConfig environment;

  List<String> validate({bool requireSupabase = false}) =>
      environment.validate(requireSupabase: requireSupabase);
}

final mentorAppConfigProvider = Provider<MentorAppConfig>(
  (ref) => MentorAppConfig.fromEnvironment(),
);

final mentorHttpClientProvider = Provider(
  (ref) => createHttpClient(
    baseUrl: ref.watch(mentorAppConfigProvider).environment.apiBaseUrl,
  ),
);

final mentorSupabaseConfigurationProvider = Provider<SupabaseConfiguration>((
  ref,
) {
  final config = ref.watch(mentorAppConfigProvider).environment;
  return SupabaseConfiguration(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
});

final mentorSupabaseClientProvider = FutureProvider(
  (ref) => initializeSupabase(ref.watch(mentorSupabaseConfigurationProvider)),
);

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MentorHomeScreen()),
  ],
);

class MentorApp extends StatelessWidget {
  const MentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MedToks Mentor',
      theme: MedtoksTheme.material,
      darkTheme: MedtoksTheme.materialDark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

class MentorHomeScreen extends ConsumerWidget {
  const MentorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref
        .watch(mentorAppConfigProvider)
        .environment
        .environment;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.all(MedtoksSpacing.lg),
                child: Text('Mentor app is ready ($environment)'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
