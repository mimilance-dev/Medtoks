import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medtoks_core/medtoks_core.dart';
import 'package:medtoks_database/medtoks_database.dart';
import 'package:medtoks_design_system/medtoks_design_system.dart';
import 'package:medtoks_networking/medtoks_networking.dart';

class MenteeAppConfig {
  const MenteeAppConfig(this.environment);

  factory MenteeAppConfig.fromEnvironment() {
    return MenteeAppConfig(AppEnvironmentConfig.fromEnvironment());
  }

  final AppEnvironmentConfig environment;

  List<String> validate({bool requireSupabase = false}) =>
      environment.validate(requireSupabase: requireSupabase);
}

final menteeAppConfigProvider = Provider<MenteeAppConfig>(
  (ref) => MenteeAppConfig.fromEnvironment(),
);

final menteeHttpClientProvider = Provider(
  (ref) => createHttpClient(
    baseUrl: ref.watch(menteeAppConfigProvider).environment.apiBaseUrl,
  ),
);

final menteeSupabaseConfigurationProvider = Provider<SupabaseConfiguration>((
  ref,
) {
  final config = ref.watch(menteeAppConfigProvider).environment;
  return SupabaseConfiguration(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
});

final menteeSupabaseClientProvider = FutureProvider(
  (ref) => initializeSupabase(ref.watch(menteeSupabaseConfigurationProvider)),
);

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MenteeHomeScreen()),
    GoRoute(
      path: '/design-system',
      builder: (context, state) => const DesignSystemShowcaseScreen(),
    ),
  ],
);

class MenteeApp extends StatelessWidget {
  const MenteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'MedToks Mentee',
      theme: AppTheme.cupertinoSystem,
      routerConfig: _router,
    );
  }
}

class MenteeHomeScreen extends ConsumerWidget {
  const MenteeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref
        .watch(menteeAppConfigProvider)
        .environment
        .environment;
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mentee app is ready ($environment)'),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () => context.push('/design-system'),
                child: const Text('Open design system'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
