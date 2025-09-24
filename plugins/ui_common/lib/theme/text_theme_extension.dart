part of ui_common;

extension TextThemeExtension on ThemeData {
  TextStyle? get bodySmallMuted   => textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withAlpha((255 * .5).toInt()));
  TextStyle? get bodyMediumMuted  => textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withAlpha((255 * .5).toInt()));
  TextStyle? get bodyLargeMuted   => textTheme.bodyLarge?.copyWith(color: textTheme.bodyLarge?.color?.withAlpha((255 * .5).toInt()));

  TextStyle? get bodySmallError   => textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer);
  TextStyle? get bodyMediumError  => textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer);
  TextStyle? get bodyLargeError   => textTheme.bodyLarge?.copyWith(color: colorScheme.onErrorContainer);

  TextStyle? get bodySmallItalic  => textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get bodyMediumItalic => textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get bodyLargeItalic  => textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic);

  TextStyle? get titleSmallError  => textTheme.titleSmall?.copyWith(color: colorScheme.onErrorContainer);
  TextStyle? get titleMediumError => textTheme.titleMedium?.copyWith(color: colorScheme.onErrorContainer);
  TextStyle? get titleLargeError  => textTheme.titleLarge?.copyWith(color: colorScheme.onErrorContainer);

  TextStyle? get titleSmallWarn   => textTheme.titleSmall?.copyWith(color: colorScheme.successVariant.onPrimary);
  TextStyle? get titleMediumWarn  => textTheme.titleMedium?.copyWith(color: colorScheme.successVariant.onPrimary);
  TextStyle? get titleLargeWarn   => textTheme.titleLarge?.copyWith(color: colorScheme.successVariant.onPrimary);

  TextStyle? get titleSmallSuccess => textTheme.titleSmall?.copyWith(color: colorScheme.successVariant.onSurface);
  TextStyle? get titleMediumSuccess=> textTheme.titleMedium?.copyWith(color: colorScheme.successVariant.onSurface);
  TextStyle? get titleLargeSuccess => textTheme.titleLarge?.copyWith(color: colorScheme.successVariant.onSurface);

  TextStyle? get titleSmallVariant => textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer);
  TextStyle? get titleMediumVariant=> textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer);
  TextStyle? get titleLargeVariant => textTheme.titleLarge?.copyWith(color: colorScheme.onPrimaryContainer);

  // TextStyle? get onWarnButtonStyle => elevatedButtonTheme.style.textStyle?.copyWith(color: colorScheme.onWarningSurface);

  // theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onErrorContainer
}