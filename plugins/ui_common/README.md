# UI Common

[![Version](https://img.shields.io/badge/version-0.0.2-blue.svg)](https://github.com/becker-antriebe/ui_common)
[![Flutter](https://img.shields.io/badge/Flutter-3.4.0+-blue.svg)](https://flutter.dev)

## Overview

UI Common is a comprehensive design system and component library providing standardized UI elements, themes, and navigation patterns for all Becker applications. It ensures visual and functional consistency across the entire Becker product ecosystem.

## Key Features

### 🎨 **Design System**
- **Consistent Theming**: Unified light and dark themes
- **Component Library**: Comprehensive reusable UI components
- **Typography System**: Standardized text styles and fonts
- **Color Palette**: Consistent color scheme with accessibility support

### 🧩 **UI Components**
- **Form Controls**: Buttons, inputs, switches, sliders
- **Navigation**: App bars, drawers, navigation patterns
- **Data Display**: Lists, grids, cards, information displays
- **Feedback**: Alerts, dialogs, progress indicators

### 🌐 **Internationalization**
- **Multi-language Support**: 11+ languages supported
- **Translation Management**: Centralized translation system
- **Localization Utilities**: Date/time and number formatting
- **RTL Support**: Right-to-left language support

### 🧭 **Navigation System**
- **GoRouter Integration**: Modern declarative routing
- **Deep Linking**: Direct navigation to specific screens
- **Stateful Navigation**: Complex navigation with multiple branches

## Usage

### Basic App Setup
```dart
import 'package:ui_common/ui_common.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UICApp(
      appTitle: 'My Becker App',
      supportedLocales: const [Locale('de'), Locale('en')],
      routes: [HomeRoute(), SettingsRoute()],
      theme: UICTheme.light(),
    );
  }
}
```

### Using Components
```dart
// Form controls
UICElevatedButton(
  onPressed: () => print('Button pressed'),
  child: Text('Click me'),
)

// Internationalization
Text('Hello'.i18n)
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  go_router: ^16.2.0
  expandable: ^5.0.1
  intl: ^0.20.2
  i18n_extension: ^15.0.4
  gettext_parser: ^0.2.0
  package_info_plus: ^8.1.2
```

## Supported Languages

- 🇩🇪 German (Deutsch)
- 🇨🇿 Czech (Čeština)
- 🇬🇧 English
- 🇪🇸 Spanish (Español)
- 🇫🇷 French (Français)
- 🇭🇺 Hungarian (Magyar)
- 🇮🇹 Italian (Italiano)
- 🇳🇱 Dutch (Nederlands)
- 🇸🇪 Swedish (Svenska)
- 🇹🇷 Turkish (Türkçe)
- 🇵🇱 Polish (Polski)

## Development

### Project Structure
```
ui_common/
├── lib/
│   ├── ui_common.dart          # Main export file
│   ├── app/                    # App framework
│   ├── scaffold/               # Scaffold system
│   ├── form_controls/          # Form components
│   ├── theme/                  # Theme system
│   └── i18n/                   # Internationalization
├── assets/locale/              # Translation files
└── example/                    # Example application
```

### Building
```bash
flutter pub get
flutter test
flutter analyze
```

## License

This project is proprietary software developed by Becker-Antriebe GmbH. All rights reserved.

## Support

For technical support:
- **Documentation**: [Internal Wiki](https://wiki.becker-antriebe.com)
- **Issues**: [Internal Issue Tracker](https://gitlab.becker-antriebe.com)
- **Email**: support@becker-antriebe.com