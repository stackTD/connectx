import 'package:flutter/material.dart';

/// Reusable card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final String? title;
  final Widget? trailing;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardChild = child;

    if (title != null) {
      cardChild = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Divider(),
          child,
        ],
      );
    }

    final card = Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? Theme.of(context).cardColor,
      margin: margin ?? const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: cardChild,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: card,
      );
    }

    return card;
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Info card for displaying key-value pairs
class InfoCard extends StatelessWidget {
  final Map<String, String> data;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const InfoCard({
    Key? key,
    required this.data,
    this.title,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: title,
      padding: padding,
      margin: margin,
      child: Column(
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Status chip widget
class StatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isActive;

  const StatusChip({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = backgroundColor ??
        (isActive ? colorScheme.primary : colorScheme.surfaceVariant);
    final effectiveTextColor = textColor ??
        (isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: effectiveTextColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button with consistent styling
class AppActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppActionButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (icon != null ? Icon(icon) : const SizedBox.shrink()),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}