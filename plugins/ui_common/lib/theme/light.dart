part of ui_common;

ThemeData get lightTheme => ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(0xFF, 0, 78, 135),
  fontFamily: 'SF-Pro',
  useMaterial3: true,
  
  colorScheme: _lightScheme,

  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    )
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStatePropertyAll(3),
      padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
      backgroundColor: WidgetStatePropertyAll(_lightScheme.surfaceContainerHighest),
      foregroundColor: WidgetStatePropertyAll(_lightScheme.onSurface),
      iconColor: WidgetStatePropertyAll(_lightScheme.onSurface),
      // shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      //   RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(5.0),
      //   ),
      // ),
    )
  ),
);

