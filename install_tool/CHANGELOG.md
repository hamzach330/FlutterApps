# Bekannte Fehler
* Unter Umständen kann es dazu kommen, dass Sticks nach dem Entdecken nicht korrekt angezeigt werden, hier hilft aktuell nur ein Applikationsneustart

# Änderungen 1.0.21 / 1.0.22
* Vereinheitlichung der Interfaces für: Android Bluetooth, Android USB, iOS Bluetooth, Mac und Windows USB
* Verbesserungen der Applikationsarchitektur

# Änderungen 1.0.20
* Englische, schwedische, spanische, tchechische Übersetzungen
* Netzwerkweiter Funk-Reset funktioniert jetzt wie erwartet
* OTA User Update temporär für SC861 Test aktiviert
* Position von Ja / Nein in Dialogen vereinheitlicht

# Änderungen 1.0.19 (HOTFIX)
* USB timeout wieder auf 0 erzwungen

# Änderungen 1.0.18
* Erweiterte Einstellungen - Alle Sensorzuordnungen löschen - entfernt alle dem Empfänger zugeordneten SC911 und SC811/861
* Übersetzungen erweitert
* Installation beenden - Abfrage, ob Stick bei Kunde oder Monteur verbleibt. Verbleibt Stick bei Monteur wird der Stick ausgelernt.
* Durch Telegramme entdecke Sensoren zeigen jetzt sofort den Wert an.
* Grafiken aktualisiert
* Anpassung BLE MTU auf 64 Byte

# Änderungen 1.0.17
* Exit Dialog angepasst
* Übersetzungen eingefügt
* Werden Sensoren durch ein ausgesendetes Telegramm entdeckt, werden die Werte sofort ausgegeben, falls vorhanden

# Änderungen 1.0.15 / 1.0.16
* Sensorzuordnung implementiert
* Sonnenschutzeinstellungen: Reaktion auf Regen / Wintermodus sind jetzt verfügbar
* Änderungen im Handling des USB-Sticks - "Stick ziehen" sollte nicht mehr so häufig notwendig sein
* Unterstützung von ausgewählten Multicast befehlen:
  - Fahr-, Wendungs- und Zwischenpositionsanfahrt
  - Sicherheitsmodus de-/aktivieren
  - Entsperren von Empfängern
  - Antriebssoftware Neustart
  - Netzvernichter (Alles auslernen und Stick neu starten)
* Für Einzelne Empfänger können jetzt Sperren in alle Richtungen gesetzt werden
* Auf der Übersicht wird angezeigt, falls ein Gerät gesperrt ist
* Die Anzahl von Geräten, die durch die Software entdeckt wurden und dem eigenen Netz zugehörig sind wird in der Seitenleiste angezeigt
* "Mesh Aktualisieren" lässt sich jetzt abbrechen
* Erste iOS Unterstützung mittels BLE Brücke
* Sonnenschutzautomatik und Memo Funktionen können jetzt de-/aktiviert werden. Es wird nicht auf Vorhandensein einer Anschlagsendlage geprüft!
* Antriebsfehler werden jetzt ausgegeben
* Es wurde ein Fehler behoben, der dazu führte, dass Werte nach einem Firmware Update nicht mehr aktualisiert wurden
* Mehrere Abfragen eingefügt, um den Benutzer vor Fehlern zu bewahren

# Änderungen 1.0.14
* Es wurde ein Fehler behoben, der verhinderte, dass nach einem erneuten Verbindungsaufbau Empfänger gefunden werden
* Es wurde ein Fehler behoben, der das Entdecken von Empfängern anhand von regulären Telegrammen verhinderte

# Änderungen 1.0.13
* Es wurde ein Fehler behoben, der dazu führte, dass Empfänger in einer Endlosschleife abgefragt wurden

# Änderungen 1.0.12
* Bessere Unterstützung für SC861

# Änderungen 1.0.11
* Übersetzungen angepasst

# Änderungen 1.0.10
* "Mesh aktualisieren" fragt jetzt im Zeitraum von 32 Sekunden 4x die Netzwerkstruktur ab
* Neue Funktion "Cache leeren": Lokal gesammelte Netzwerkinformationen verwerfen und Mesh aktualisieren auslösen
* Sensorzuordnung
* Bessere Hinweise bei aktiver Mehrfachauswahl (Sensorzuordnung, Sonnenschutzkonfiguration)
* UI Stabilität & Anpassung; Verbessertes Layout bei kleinen Bildschirmen
* Android Stabilitätsanpassungen

# Änderungen 1.0.9
* Es wurde ein Fehler behoben, der dazu führte, dass nicht alle Empfänger in der Rasteransicht angezeigt wurden
* Das teachin-handling wurde angepasst
* Der Parent wird jetzt beim aktualisieren der Mesh Struktur neu gesetzt

# Änderungen 1.0.8
* Tooltip timeouts auf 0 gesetzt (Tooltips werden jetzt sofort geschlossen, wenn die Maus den entsprechenden Bereich verlässt)
* Adaptives Layout und Layoutanpassungen
* Android Unterstützung
* Die Liste "Meine Installation" wird nicht mehr komplett geleert, wenn "Mesh aktualisieren" gedrückt wird
* Empfängerinformationen werden jetzt auf Unterseiten eines Empfängers angezeigt
* Bei VC / LC wird zusätzlich zum Gerätetyp der Initiator angezeigt
* Der Batteriezustand von Empfängern wird jetzt ausgewertet
* Dialoge sind jetzt in der Breite limitiert
* Abhängigkeiten aktualisiert

# Änderungen 1.0.7
* Es wurde ein Fehler behoben, der das Abschließen von OTA Updates auf Windows verhindert hat

# Änderungen 1.0.6
* Applikationsgröße reduziert
* Es wurde ein Fehler behoben, der dazu führte, dass nicht alle Kindknoten in einem Mesh angezeigt wurden
* HomeeCube und CentronicPLUS Stick werden jetzt als CentronicPLUS Stick angezeigt

# Änderungen 1.0.5
* Es wurde ein Fehler behoben, der dazu führte, dass die Sonnenschutzeinstellungen nicht mehr verlassen werden konnten
* In der Listenansicht werden Geräte jetzt anhand der Mesh-Struktur eingerückt

# Änderungen 1.0.3:
* Buttons, die nur Icons darstellen wurden mit Tooltips versehen
* Es wird jetzt zwischen VC und LC unterschieden, Geräte zeigen bei der Betriebsartkonfiguration nur noch die verfügbaren Optionen an
* Der Name der ausführbaren Datei wurde angepasst, Applikationstitel angepasst
* Unnötige Print-statements  wurden entfernt
* Die Wendung bei Jalousien funktioniert jetzt wie erwartet
* Ein use after dispose Fehler wurde behoben
* Analogwerte werden bei eingehenden Telegrammen jetzt dargestellt
* Es wurde ein Navigationsfehler beim Auflösen von Dialogen behoben
* Beim OTA wurde ein Darstellungsfehler nach dem Senden des letzten Chunks behoben
* Es wurden einige Warnungen im Quellcode behoben
* Beim Verlassen der Sonnenschutzeinstellungen wird eine Abfrage „Änderungen speichern“ aufgerufen
* Beim Speichern der Sonnenschutzeinstellungen wird jetzt ein Aktivitätsindikator angezeigt
* Sonnenschutzeinstellungen werden jetzt erst nach dem Click auf den Speichern Button geschrieben
* Beim OTA wird ein Statusbalken in der Taskbar / Dock angezeigt
* Nach Abschluss des OTA wird die Applikation wiederhergestellt, falls minimiert
* Verbessertes Telegrammhandling, für Nachrichten die in mehreren Chunks vom USB-Stick gemeldet werden
* Die Mindestgröße des Fensters wurde auf 1440 x 800 festgelegt
