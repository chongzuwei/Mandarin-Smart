import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Enhanced Button Components ─────────────────────────────────────

/// Primary action button with gradient and animation
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final EdgeInsets padding;
  final Widget? icon;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
    this.icon,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isDisabled || widget.isLoading
          ? null
          : (_) => _animationController.forward(),
      onTapUp: widget.isDisabled || widget.isLoading
          ? null
          : (_) {
            _animationController.reverse();
            widget.onPressed();
          },
      onTapCancel: widget.isDisabled || widget.isLoading
          ? null
          : () => _animationController.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95)
            .animate(_animationController),
        child: Container(
          height: widget.height,
          padding: widget.padding,
          decoration: AppTheme.buildButtonDecoration(
            isPressed: _animationController.value > 0,
            isDisabled: widget.isDisabled,
          ),
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.textPrimary,
                    ),
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: AppTheme.spacingSm),
                    ],
                    Text(
                      widget.label,
                      style: AppTheme.buttonText.copyWith(
                        color: widget.isDisabled
                            ? AppTheme.textTertiary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDisabled;
  final double height;
  final Color? textColor;
  final Widget? icon;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.height = 48,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDisabled
              ? AppTheme.dividerColor.withValues(alpha: 0.3)
              : AppTheme.primaryRed,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppTheme.spacingSm),
              ],
              Text(
                label,
                style: AppTheme.buttonText.copyWith(
                  color: isDisabled ? AppTheme.textTertiary : AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card Components ────────────────────────────────────────────────

/// Glass-morphism style card with enhanced styling
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingLg),
    this.borderRadius = AppTheme.radiusLg,
    this.shadows,
    this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = AppTheme.buildCardDecoration(
      shadows: shadows,
      borderRadius: borderRadius,
    );

    Widget card = Container(
      padding: padding,
      decoration: backgroundColor != null
          ? decoration.copyWith(
              color: backgroundColor,
              gradient: null,
            )
          : decoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Elevated info card with icon and action
class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppTheme.accentGold,
    required this.backgroundColor,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      backgroundColor: backgroundColor.withValues(alpha: 0.08),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.labelMedium),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppTheme.spacingMd),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ── Status Badge Components ────────────────────────────────────────

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final EdgeInsets padding;

  const StatusBadge({
    Key? key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: AppTheme.buildBadgeDecoration(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Success status badge
class SuccessBadge extends StatelessWidget {
  final String label;

  const SuccessBadge({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: label,
      backgroundColor: AppTheme.successGreen,
      textColor: AppTheme.successGreen,
      borderColor: AppTheme.successGreen,
      icon: Icons.check_circle_outline,
    );
  }
}

/// Warning status badge
class WarningBadge extends StatelessWidget {
  final String label;

  const WarningBadge({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: label,
      backgroundColor: AppTheme.warningOrange,
      textColor: AppTheme.warningOrange,
      borderColor: AppTheme.warningOrange,
      icon: Icons.warning_outlined,
    );
  }
}

/// Error status badge
class ErrorBadge extends StatelessWidget {
  final String label;

  const ErrorBadge({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: label,
      backgroundColor: AppTheme.errorRed,
      textColor: AppTheme.errorRed,
      borderColor: AppTheme.errorRed,
      icon: Icons.cancel_outlined,
    );
  }
}

// ── Input Components ───────────────────────────────────────────────

/// Enhanced text input field
class AppTextField extends StatefulWidget {
  final String hintText;
  final String? label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    Key? key,
    required this.hintText,
    this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      decoration: AppTheme.buildInputDecoration(
        hintText: widget.hintText,
        label: widget.label,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}

// ── Empty State Component ──────────────────────────────────────────

/// Empty state placeholder
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final Color iconColor;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.iconColor = AppTheme.accentGold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          Text(
            title,
            style: AppTheme.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXl,
            ),
            child: Text(
              description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppTheme.spacingXl),
            action!,
          ],
        ],
      ),
    );
  }
}

// ── Loading Component ──────────────────────────────────────────────

/// Custom loading indicator
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const AppLoadingIndicator({
    Key? key,
    this.size = 40,
    this.color = AppTheme.primaryRed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 2.5,
      ),
    );
  }
}

// ── Divider Component ──────────────────────────────────────────────

/// Enhanced divider with optional text
class AppDivider extends StatelessWidget {
  final String? text;
  final Color color;
  final double height;

  const AppDivider({
    Key? key,
    this.text,
    this.color = AppTheme.dividerColor,
    this.height = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Divider(
        color: color,
        height: height,
        thickness: height,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(color: color, height: height, thickness: height),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            text!,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
          ),
        ),
        Expanded(
          child: Divider(color: color, height: height, thickness: height),
        ),
      ],
    );
  }
}

// ── Section Header Component ───────────────────────────────────────

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.headingSmall),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                subtitle!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ],
        ),
        if (action != null) action!,
      ],
    );
  }
}
