part of ui_common;

extension Localization on String {
  static const List<Locale> supported = [
    Locale('cs', ''),
    Locale('de', ''),
    Locale('en', ''),
    Locale('es', ''),
    Locale('fr', ''),
    Locale('hu', ''),
    Locale('it', ''),
    Locale('nl', ''),
    Locale('sv', ''),
    Locale('tr', ''),
  ];

  static Translations _t = Translations.byLocale('de') + {
    'de': 'Lade Einstellungen...',
    'en': 'Loading settings...',
    'fr': 'Chargement des paramètres...',
    'hu': 'Beállítások betöltése...',
    'es': 'Cargando ajustes...',
    'cs': 'Nahrávám nastavení...',
    'sv': 'Laddar inställningar...',
    'it': 'Caricare impostazioni...',
    'nl': 'Instellingen laden...',
    'tr': 'Ayarlar yükleniyor...'
  };

  static String get locale {
    Translations.missingKeyCallback = (_, __) => null;

    try {
      final locale = I18n.locale.languageCode;
      if(supported.where((l) => l.languageCode == locale).isNotEmpty) {
        return locale;
      }
    } catch(e) {
      print("Failed to get locale: $e");
    }
    return 'en';
  }

  static Future<void> loadTranslations() async {
    try {
      Translations translations =
        Translations.byLocale(locale) + await JSONImporter().fromAssetDirectory('packages/ui_common/assets/locale');
      Localization._t = translations;
      dev.log("Loaded ${translations.length} translations for locale '$locale'", name: "i18n");
    } catch(e) {
      print("Failed to load translation from Assets: assets/locale/$locale.json");
    }
    return;
  }

  //   static Future<void> loadTranslations() async {
  //   try {
  //     Translations translations =
  //       Translations.byLocale(locale) + await JSONImporter().fromAssetFile(locale, "lib/assets/locale/$locale.json");
  //     Localization._t = translations;
  //   } catch(e) {
  //     print("Failed to load translation from Assets: assets/locale/$locale.json");
  //   }
  //   return;
  // }


  // String get i18n => localize(this, _t, languageTag: _locale);
  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
  String version(Object modifier) => localizeVersion(modifier, this, _t);
  Map<String?, String> allVersions() => localizeAllVersions(this, _t);
}
