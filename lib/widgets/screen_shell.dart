import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared background + padding + card container for consistency across screens.
///
/// Note: this shell is primarily for auth/profile style pages.
class ScreenShell extends StatelessWidget {
  final String? title;
  final Widget? header;
  final Widget child;
  final EdgeInsets padding;
  final double cardRadius;
  final List<BoxShadow>? cardShadows;
  final EdgeInsets cardPadding;

  const ScreenShell({
    super.key,
    this.title,
    this.header,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
    this.cardRadius = AppTheme.radiusXl,
    this.cardShadows,
    this.cardPadding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: Container(
                decoration: AppTheme.buildCardDecoration(
                  borderRadius: cardRadius,
                  shadows: cardShadows ?? AppTheme.elevatedShadow,
                ),
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (header != null) ...[
                      header!,
                      const SizedBox(height: 16),
                    ] else if (title != null) ...[
                      Text(
                        title!,
                        style: AppTheme.headingLarge
                            .copyWith(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                    ],
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticatedScreenShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final double cardRadius;
  final double maxContentWidth;
  final EdgeInsetsGeometry cardPadding;

  const AuthenticatedScreenShell({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    required this.child,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 16, 24, 32),
    this.cardRadius = AppTheme.radiusXl,
    this.maxContentWidth = 1040,
    this.cardPadding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final background = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ) ??
                              AppTheme.headingMedium.copyWith(
                                color: onSurface,
                              ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                  color: onSurface.withValues(alpha: 0.72),
                                ) ??
                                AppTheme.bodyMedium.copyWith(
                                  color: onSurface.withValues(alpha: 0.72),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) ...[
                    const SizedBox(width: 16),
                    Row(children: actions!),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: contentPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Container(
                      decoration: AppTheme.buildCardDecoration(
                        borderRadius: cardRadius,
                        shadows: AppTheme.softShadow,
                      ),
                      padding: cardPadding,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

