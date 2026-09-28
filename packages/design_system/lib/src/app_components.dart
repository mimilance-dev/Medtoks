import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show CircleAvatar, LinearProgressIndicator, Material, Theme;

import 'app_tokens.dart';

bool _isDark(BuildContext context) {
  return MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
      Theme.of(context).brightness == Brightness.dark ||
      CupertinoTheme.of(context).brightness == Brightness.dark;
}

Color _surfaceColor(BuildContext context) =>
    _isDark(context) ? AppColors.darkSurface : AppColors.lightSurface;
Color _elevatedColor(BuildContext context) =>
    _isDark(context) ? AppColors.darkElevated : AppColors.lightElevated;
Color _inkColor(BuildContext context) =>
    _isDark(context) ? AppColors.darkInk : AppColors.lightInk;
Color _mutedColor(BuildContext context) =>
    _isDark(context) ? AppColors.darkMuted : AppColors.lightMuted;
Color _borderColor(BuildContext context) =>
    _isDark(context) ? AppColors.darkBorder : AppColors.lightBorder;

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expands = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expands;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: expands ? double.infinity : null,
        child: CupertinoButton(
          onPressed: enabled ? onPressed : null,
          color: AppColors.brand,
          disabledColor: AppColors.brand.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Row(
              mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const CupertinoActivityIndicator(
                    color: AppColors.lightPrimaryText,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ] else if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.lightPrimaryText),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: AppColors.lightPrimaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expands = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expands;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ink = _inkColor(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: expands ? double.infinity : null,
        child: CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: _surfaceColor(context),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: _borderColor(context)),
            ),
            child: Row(
              mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: ink),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(color: ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.trailing,
    this.errorText,
    this.helperText,
    this.semanticLabel,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autocorrect = true,
    this.maxLines = 1,
    super.key,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? leading;
  final Widget? trailing;
  final String? errorText;
  final String? helperText;
  final String? semanticLabel;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autocorrect;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final textColor = _inkColor(context);
    final fieldLabel = semanticLabel ?? label ?? placeholder ?? 'Text field';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.label.copyWith(color: textColor)),
          const SizedBox(height: AppSpacing.sm),
        ],
        Semantics(
          textField: true,
          label: fieldLabel,
          child: CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            placeholder: placeholder,
            placeholderStyle: AppTypography.body.copyWith(
              color: dark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
            style: AppTypography.body.copyWith(color: textColor),
            prefix: leading == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    child: leading,
                  ),
            suffix: trailing == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: trailing,
                  ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: enabled ? _surfaceColor(context) : _elevatedColor(context),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: errorText == null
                    ? _borderColor(context)
                    : AppColors.danger,
              ),
            ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            enabled: enabled,
            autocorrect: autocorrect,
            maxLines: obscureText ? 1 : maxLines,
            cursorColor: AppColors.brand,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
        ),
        if (errorText != null || helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText ?? helperText!,
            style: AppTypography.caption.copyWith(
              color: errorText == null
                  ? _mutedColor(context)
                  : AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.placeholder = 'Search',
    this.semanticLabel,
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String placeholder;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      placeholder: placeholder,
      semanticLabel: semanticLabel ?? placeholder,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      leading: Icon(AppIcons.search, size: 19, color: _mutedColor(context)),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.onTap,
    this.semanticLabel,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? _surfaceColor(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: _borderColor(context)),
        boxShadow: dark ? AppShadows.darkCard : AppShadows.card,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) {
      return Semantics(container: true, label: semanticLabel, child: card);
    }
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: CupertinoButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: card,
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.semanticLabel,
    this.image,
    this.initials,
    this.size = 44,
    this.backgroundColor,
    super.key,
  });

  final String semanticLabel;
  final ImageProvider? image;
  final String? initials;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor:
              backgroundColor ?? AppColors.brand.withValues(alpha: 0.12),
          backgroundImage: image,
          child: image == null
              ? Text(
                  initials ?? _initials(semanticLabel),
                  style: AppTypography.label.copyWith(color: AppColors.brand),
                )
              : null,
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    return parts
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
  }
}

enum AppBadgeTone { neutral, brand, success, warning, danger }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final AppBadgeTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final (background, foreground) = switch (tone) {
      AppBadgeTone.neutral => (_elevatedColor(context), _mutedColor(context)),
      AppBadgeTone.brand => (
        AppColors.brand.withValues(alpha: dark ? 0.2 : 0.1),
        dark ? const Color(0xFF78D0CC) : AppColors.brand,
      ),
      AppBadgeTone.success => (
        dark ? AppColors.darkSuccessSurface : AppColors.lightSuccessSurface,
        dark ? AppColors.darkSuccessText : AppColors.success,
      ),
      AppBadgeTone.warning => (
        dark ? AppColors.darkWarningSurface : AppColors.lightWarningSurface,
        dark ? AppColors.darkWarningText : AppColors.amber,
      ),
      AppBadgeTone.danger => (
        dark ? AppColors.darkDangerSurface : AppColors.lightDangerSurface,
        dark ? AppColors.darkDangerText : AppColors.danger,
      ),
    };
    return Semantics(
      label: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.leading,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? leading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.lightPrimaryText
        : _inkColor(context);
    return Semantics(
      button: true,
      selected: selected,
      enabled: onSelected != null,
      label: semanticLabel ?? label,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onSelected == null ? null : () => onSelected!(!selected),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand : _surfaceColor(context),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? AppColors.brand : _borderColor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.label.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon = CupertinoIcons.tray,
    this.action,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '$title. $message',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 42, color: _mutedColor(context)),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    color: _inkColor(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: _mutedColor(context),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    this.onRetry,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: message,
      icon: AppIcons.error,
      semanticLabel: semanticLabel ?? 'Error: $title. $message',
      action: onRetry == null
          ? null
          : AppSecondaryButton(
              label: 'Try again',
              onPressed: onRetry,
              icon: CupertinoIcons.refresh,
            ),
    );
  }
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    this.label = 'Loading',
    this.semanticLabel,
    super.key,
  });

  final String label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? label,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 14),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: _mutedColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.title,
    required this.child,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final Widget child;
  final String? semanticLabel;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    String? semanticLabel,
    bool useRootNavigator = true,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (context) => AppBottomSheet(
        title: title,
        semanticLabel: semanticLabel,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: semanticLabel ?? title,
      child: Material(
        color: _surfaceColor(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.md,
                AppSpacing.xxl,
                AppSpacing.xxl + bottomInset,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _borderColor(context),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    title,
                    style: AppTypography.headline.copyWith(
                      color: _inkColor(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Flexible(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.message,
    required this.actions,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String message;
  final List<AppDialogAction> actions;
  final String? semanticLabel;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<AppDialogAction> actions,
    String? semanticLabel,
    bool barrierDismissible = true,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        actions: actions,
        semanticLabel: semanticLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: semanticLabel ?? title,
      child: CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(message),
        ),
        actions: [
          for (final action in actions)
            CupertinoDialogAction(
              isDestructiveAction: action.isDestructive,
              isDefaultAction: action.isDefault,
              onPressed: action.onPressed,
              child: Text(action.label),
            ),
        ],
      ),
    );
  }
}

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: AppTypography.body.copyWith(color: _inkColor(context)),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  DefaultTextStyle(
                    style: AppTypography.bodySmall.copyWith(
                      color: _mutedColor(context),
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: onTap == null
          ? content
          : CupertinoButton(
              onPressed: onTap,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              child: content,
            ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headline.copyWith(
                  color: _inkColor(context),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: _mutedColor(context),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    this.value,
    this.label = 'Progress',
    this.semanticLabel,
    super.key,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final String label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final percentage = value == null ? null : '${(value! * 100).round()}%';
    return Semantics(
      label: semanticLabel ?? label,
      value: percentage,
      child: value == null
          ? const CupertinoActivityIndicator()
          : ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: _borderColor(context),
                color: AppColors.brand,
                semanticsLabel: null,
              ),
            ),
    );
  }
}

class AppSubscriptionCard extends StatelessWidget {
  const AppSubscriptionCard({
    required this.title,
    required this.price,
    required this.interval,
    required this.features,
    required this.actionLabel,
    required this.onPressed,
    this.badge,
    this.selected = false,
    this.semanticLabel,
    super.key,
  });

  final String title;
  final String price;
  final String interval;
  final List<String> features;
  final String actionLabel;
  final VoidCallback? onPressed;
  final String? badge;
  final bool selected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ink = _inkColor(context);
    return AppCard(
      semanticLabel: semanticLabel ?? '$title subscription, $price $interval',
      backgroundColor: selected
          ? AppColors.brand.withValues(alpha: _isDark(context) ? 0.12 : 0.06)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headline.copyWith(color: ink),
                ),
              ),
              if (badge != null)
                AppBadge(label: badge!, tone: AppBadgeTone.brand),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.xs,
            children: [
              Text(price, style: AppTypography.title.copyWith(color: ink)),
              Text(
                interval,
                style: AppTypography.bodySmall.copyWith(
                  color: _mutedColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final feature in features) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    AppIcons.success,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.bodySmall.copyWith(color: ink),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(label: actionLabel, onPressed: onPressed, expands: true),
        ],
      ),
    );
  }
}
