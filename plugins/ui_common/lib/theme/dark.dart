part of ui_common;

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(0xFF, 0, 78, 135),
  fontFamily: 'SF-Pro',
  useMaterial3: true,

  colorScheme: _darkScheme,
  
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.grey.shade900
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    )
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      // elevation: WidgetStatePropertyAll(3),
      padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
      backgroundColor: WidgetStatePropertyAll(_lightScheme.inverseSurface),
      foregroundColor: WidgetStatePropertyAll(_lightScheme.onPrimary),
      iconColor: WidgetStatePropertyAll(_lightScheme.onPrimary),
      // shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      //   RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(5.0),
      //   ),
      // ),
    )
  ),
);