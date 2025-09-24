# Becker Tool

[![pipeline status](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/badges/master/pipeline.svg)](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/commits/master) 

[![coverage report](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/badges/master/coverage.svg)](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/commits/master) 

[![Latest Release](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/badges/release.svg)](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/releases) 



Android, Windows, macOS

Centronic PLUS Einrichtungswerkzeug für den Fachhandel

## Allgemein
Build min Version: Flutter 3.10.6
````
cd app
flutter pub get
flutter run -d (windows|macos) --verbose (--release)
````

## Tasks
### Extract i18n strings
Übersetzungsschlüssel werden extrahiert und in strings.pot gespeichert
<br>
### Mason: gen centronic_plus
Erzeugt Telegrammdecoder anhand der config Datei
<br>
### Doc: centronic_plus
Erzeugt Dokumentation
<br>
### Test: centronic_plus
Automatisierte Tests ausführen
<br>
<br>
## Unterprojekte
<br>
### ui_common
Geteilte UI Komponenten, die von Projekten in diesem Repositorium verwendet werden
<br>
### centronic_plus
Dart Centronic PLUS Implementierung
<br>
### app
Das Centronic PLUS Einrichtungswerkzeug
<br>
### bin
Helferprojekte (Aktuell nur Extrahieren von i18n Strings)
