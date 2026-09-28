import 'package:flutter/cupertino.dart';

import 'app_components.dart';
import 'app_tokens.dart';
import 'medtoks_theme.dart';

class DesignSystemShowcaseScreen extends StatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  State<DesignSystemShowcaseScreen> createState() =>
      _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState
    extends State<DesignSystemShowcaseScreen> {
  final _searchController = TextEditingController();
  final _textController = TextEditingController();
  bool _darkMode = false;
  bool _selectedChip = true;
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _darkMode ? Brightness.dark : Brightness.light;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(platformBrightness: brightness),
      child: CupertinoTheme(
        data: _darkMode ? AppTheme.cupertinoDark : AppTheme.cupertinoLight,
        child: CupertinoPageScaffold(
          backgroundColor: _darkMode
              ? AppColors.darkCanvas
              : AppColors.lightCanvas,
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Design system'),
            trailing: Semantics(
              label: 'Dark appearance',
              child: CupertinoSwitch(
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 420
                          ? AppSpacing.lg
                          : AppSpacing.xxl,
                      vertical: AppSpacing.xxl,
                    ),
                    children: [
                      Text(
                        'MedToks foundations',
                        style: AppTypography.display.copyWith(
                          color: _darkMode
                              ? AppColors.darkInk
                              : AppColors.lightInk,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'A calm, focused toolkit for learning and mentorship.',
                        style: AppTypography.body.copyWith(
                          color: _darkMode
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const _ShowcaseSection(
                        title: 'Palette',
                        subtitle:
                            'Semantic color roles adapt across appearances.',
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _ColorSwatch(name: 'Brand', color: AppColors.brand),
                            _ColorSwatch(name: 'Coral', color: AppColors.coral),
                            _ColorSwatch(name: 'Amber', color: AppColors.amber),
                            _ColorSwatch(
                              name: 'Success',
                              color: AppColors.success,
                            ),
                            _ColorSwatch(
                              name: 'Canvas',
                              color: AppColors.lightCanvas,
                            ),
                            _ColorSwatch(
                              name: 'Ink',
                              color: AppColors.lightInk,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _ShowcaseSection(
                        title: 'Typography and spacing',
                        subtitle: 'Text styles inherit platform scaling.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Display', style: AppTypography.display),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Section title',
                              style: AppTypography.headline,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Body copy respects the system text scale.',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Wrap(
                              spacing: AppSpacing.xl,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _SpacingMark(label: 'xs', size: AppSpacing.xs),
                                _SpacingMark(label: 'sm', size: AppSpacing.sm),
                                _SpacingMark(label: 'lg', size: AppSpacing.lg),
                                _SpacingMark(
                                  label: 'xxl',
                                  size: AppSpacing.xxl,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _ShowcaseSection(
                        title: 'Actions and fields',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppButton(
                              label: _loading ? 'Working' : 'Primary action',
                              icon: CupertinoIcons.arrow_right,
                              isLoading: _loading,
                              onPressed: () =>
                                  setState(() => _loading = !_loading),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const AppSecondaryButton(
                              label: 'Secondary action',
                              icon: CupertinoIcons.book,
                              onPressed: _noop,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppTextField(
                              label: 'Email address',
                              placeholder: 'name@example.com',
                              controller: _textController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              semanticLabel: 'Email address',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppSearchField(
                              controller: _searchController,
                              placeholder: 'Search learning resources',
                              semanticLabel: 'Search learning resources',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _ShowcaseSection(
                        title: 'Cards, badges, and chips',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppCard(
                              semanticLabel: 'Interactive resource card',
                              child: AppListTile(
                                title: const Text('Clinical reasoning'),
                                subtitle: const Text('Updated this week'),
                                leading: const AppAvatar(
                                  semanticLabel: 'Clinical reasoning mentor',
                                  initials: 'CR',
                                ),
                                trailing: const Icon(AppIcons.arrowRight),
                                onTap: _noop,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                AppBadge(
                                  label: 'Active',
                                  tone: AppBadgeTone.success,
                                ),
                                AppBadge(
                                  label: 'In review',
                                  tone: AppBadgeTone.warning,
                                ),
                                AppBadge(
                                  label: 'Action needed',
                                  tone: AppBadgeTone.danger,
                                ),
                                AppBadge(
                                  label: 'Recommended',
                                  tone: AppBadgeTone.brand,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppChip(
                              label: 'FMGE',
                              selected: _selectedChip,
                              onSelected: (value) =>
                                  setState(() => _selectedChip = value),
                              semanticLabel: 'Filter by FMGE',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _ShowcaseSection(
                        title: 'States and progress',
                        child: Column(
                          children: [
                            const AppProgressIndicator(
                              value: 0.68,
                              label: 'Course completion',
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            const AppLoadingState(label: 'Syncing study plan'),
                            const SizedBox(height: AppSpacing.lg),
                            AppErrorState(
                              title: 'Unable to load updates',
                              message: 'Your saved work is still available.',
                              onRetry: _noop,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const AppEmptyState(
                              title: 'Nothing due today',
                              message: 'Your next study task will appear here.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _ShowcaseSection(
                        title: 'Lists and overlays',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppSectionHeader(
                              title: 'Your learning plan',
                              subtitle: 'A clear next step for today.',
                              trailing: AppBadge(label: '3 tasks'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppListTile(
                              title: const Text(
                                'Review respiratory physiology',
                              ),
                              subtitle: const Text('Due tomorrow · 25 min'),
                              leading: const Icon(CupertinoIcons.book),
                              trailing: const Icon(AppIcons.arrowRight),
                              onTap: _noop,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                AppSecondaryButton(
                                  label: 'Open sheet',
                                  onPressed: () => AppBottomSheet.show<void>(
                                    context,
                                    title: 'Quick filters',
                                    child: const Text(
                                      'A reusable, scroll-safe sheet.',
                                    ),
                                  ),
                                ),
                                AppSecondaryButton(
                                  label: 'Open dialog',
                                  onPressed: () => AppDialog.show<void>(
                                    context,
                                    title: 'Keep this change?',
                                    message:
                                        'This dialog uses native Cupertino actions.',
                                    actions: [
                                      AppDialogAction(
                                        label: 'Cancel',
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      AppDialogAction(
                                        label: 'Continue',
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        isDefault: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _ShowcaseSection(
                        title: 'Subscription presentation',
                        child: AppSubscriptionCard(
                          title: 'Focused preparation',
                          price: '₹1,499',
                          interval: '/ month',
                          features: const [
                            'Exam-specific learning library',
                            'Mentor messaging and study plans',
                          ],
                          actionLabel: 'Choose plan',
                          badge: 'Popular',
                          selected: true,
                          onPressed: _noop,
                          semanticLabel:
                              'Focused preparation subscription option',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _noop() {}
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name color',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(color: AppColors.lightBorder),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(name, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _SpacingMark extends StatelessWidget {
  const _SpacingMark({required this.label, required this.size});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label spacing, ${size.toInt()} points',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: size, height: 16, color: AppColors.brand),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
