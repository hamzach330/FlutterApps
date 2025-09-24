part of ui_common;

enum UICColorScheme {
  none, error, warn, success, variant
}

extension UICButtonStyles on ThemeData {
  double get defaultWhiteSpace => 10;
  double get defaultButtonIconSize => 24;

  /// Elevated Button styles

  ButtonStyle get defaultButtonStyle => ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.only(
      top: defaultWhiteSpace * 1.5,
      bottom: defaultWhiteSpace * 1.5,
      left: defaultWhiteSpace,
      right: defaultWhiteSpace,
    )),
    iconSize: WidgetStatePropertyAll(24),
    elevation: WidgetStatePropertyAll(1),
    shadowColor: WidgetStatePropertyAll(Colors.black),
    iconColor: WidgetStatePropertyAll(colorScheme.onSurface),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
  );

  ButtonStyle get errorButtonStyle => defaultButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(colorScheme.errorVariant.surfaceTint),
    backgroundColor: WidgetStatePropertyAll(colorScheme.errorVariant.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.errorVariant.onPrimaryContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.errorVariant.onPrimaryContainer),
  );

  ButtonStyle get warnButtonStyle => defaultButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(colorScheme.warnVariant.surfaceTint),
    backgroundColor: WidgetStatePropertyAll(colorScheme.warnVariant.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.warnVariant.onPrimaryContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.warnVariant.onPrimaryContainer),
  );

  ButtonStyle get successButtonStyle => defaultButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(colorScheme.successVariant.surfaceTint),
    backgroundColor: WidgetStatePropertyAll(colorScheme.successVariant.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.successVariant.onPrimaryContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.successVariant.onPrimaryContainer),
  );

  ButtonStyle get variantButtonStyle => defaultButtonStyle.copyWith(
    backgroundColor: WidgetStatePropertyAll(colorScheme.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
  );

  /// Text Button styles

  ButtonStyle get defaultTextButtonStyle => ButtonStyle(
    // textStyle: WidgetStatePropertyAll(TextStyle(decoration: TextDecoration.underline)),
    // surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    // overlayColor: WidgetStatePropertyAll(Colors.transparent),
    // minimumSize: WidgetStatePropertyAll(Size(56, 0))
  );

  ButtonStyle get errorTextButtonStyle => defaultTextButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    foregroundColor: WidgetStatePropertyAll(colorScheme.onErrorContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.onErrorContainer),
  );

  ButtonStyle get warnTextButtonStyle => defaultTextButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    foregroundColor: WidgetStatePropertyAll(colorScheme.warnVariant.primary),
    iconColor: WidgetStatePropertyAll(colorScheme.warnVariant.primary),
  );

  ButtonStyle get successTextButtonStyle => defaultTextButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    foregroundColor: WidgetStatePropertyAll(colorScheme.successVariant.onPrimaryContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.successVariant.onPrimaryContainer),
  );

  ButtonStyle get variantTextButtonStyle => defaultTextButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
    iconColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
  );


  /// Icon Button styles
  
  ButtonStyle get defaultIconButtonStyle => ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    iconSize: WidgetStatePropertyAll(defaultButtonIconSize),
    backgroundColor: WidgetStatePropertyAll(colorScheme.secondary),
    foregroundColor: WidgetStatePropertyAll(colorScheme.onSecondary),

    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultWhiteSpace)
    )),
    elevation: WidgetStatePropertyAll(4),
    shadowColor: WidgetStatePropertyAll(Colors.black),
  );

  ButtonStyle get errorIconButtonStyle => defaultIconButtonStyle.copyWith(
    backgroundColor: WidgetStatePropertyAll(colorScheme.errorVariant.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.errorVariant.onPrimaryContainer),
  );

  ButtonStyle get warnIconButtonStyle => defaultIconButtonStyle.copyWith(
    backgroundColor: WidgetStatePropertyAll(colorScheme.warnVariant.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.warnVariant.onPrimaryContainer),
  );

  ButtonStyle get successIconButtonStyle => defaultIconButtonStyle.copyWith(
    surfaceTintColor: WidgetStatePropertyAll(colorScheme.successVariant.surfaceTint),
    backgroundColor: WidgetStatePropertyAll(colorScheme.successVariant.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.successVariant.onPrimaryContainer),
  );

  ButtonStyle get variantIconButtonStyle => defaultIconButtonStyle.copyWith(
    backgroundColor: WidgetStatePropertyAll(colorScheme.primaryContainer),
    foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
  );
}
