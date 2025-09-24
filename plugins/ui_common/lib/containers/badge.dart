part of '../../ui_common.dart';

/// A lightweight Badge widget with border support.
/// - To show a simple dot: set `label: null` and provide `size` (or use default).
/// - For a badge with content (icon/text): provide `label`; size is based on padding/content.
/// - Position can be adjusted with `alignment` + `offset`.
class UICBadge extends StatelessWidget {
  const UICBadge({
    super.key,
    required this.child,
    this.label,
    this.isVisible = true,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.size = 16, // only relevant for Dot/Circle mode
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topRight,
    this.offset = const Offset(6, -6),
    this.elevation = 0.0,
  }) : assert(shape == BoxShape.circle || borderRadius != null,
         'For non-circular badges please provide borderRadius.');

  /// The base widget (e.g., an icon) that the badge is attached to.
  final Widget child;

  /// Content inside the badge (icon or text). If null => "Dot" mode.
  final Widget? label;

  /// Whether the badge should be visible.
  final bool isVisible;

  /// Background color of the badge. Defaults to Theme.colorScheme.error.
  final Color? backgroundColor;

  /// Border color of the badge. Defaults to Theme.colorScheme.surface.
  final Color? borderColor;

  /// Width of the badge border.
  final double borderWidth;

  /// Shape of the badge (circle or rounded rectangle).
  final BoxShape shape;

  /// Corner radius for rectangular badges.
  final BorderRadius? borderRadius;

  /// Fixed size for Dot/Circle badges. Only used when `label == null` or `shape == BoxShape.circle`.
  final double? size;

  /// Inner padding of the badge (applies when `label != null`).
  final EdgeInsets padding;

  /// Position of the badge relative to the child.
  final Alignment alignment;

  /// Fine-tune position (pixel offset).
  final Offset offset;

  /// Optional shadow below the badge.
  final double elevation;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return child;

    final Color bg = backgroundColor ?? Theme.of(context).colorScheme.error;
    final Color br = borderColor ?? Theme.of(context).colorScheme.surface;

    final Widget badge = _BadgeBody(
      label: label,
      backgroundColor: bg,
      borderColor: br,
      borderWidth: borderWidth,
      shape: shape,
      borderRadius: borderRadius,
      size: size,
      padding: padding,
      elevation: elevation,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          width: size,
          height: size,
          right: 0,
          top: 0,
          child: Transform.translate(
            offset: offset,
            child: badge
          ),
        ),
      ],
    );
  }
}

class _BadgeBody extends StatelessWidget {
  const _BadgeBody({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shape,
    required this.borderRadius,
    required this.size,
    required this.padding,
    required this.elevation,
  });

  final Widget? label;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double? size;
  final EdgeInsets padding;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Padding(
        padding: padding,
        child: label ?? SizedBox(),
      ),
    );
  }
}
