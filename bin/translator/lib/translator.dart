// import 'dart:io';
// import 'dart:convert';
// import 'package:openai_dart/openai_dart.dart';
// import 'package:args/args.dart';
// import 'package:path/path.dart' as path;

// const OAI_BASE_URL = "http://192.168.178.21:11434/v1";
// const API_KEY  = "***";
// const COMPLETION_MODEL = "mistral-small:8k";

// String getPrompt (String locales, String examples, String form) => '''
// Translate the Form at the end of the messages to the following languages: $locales.
// The context of this translation is a mobile app for controlling home automation devices.

// Leave standalone enum and constants empty. For example:
// JAL_SENS_SEC, PAR_MARKI, ACT_DOOR, INROOM_SENS

// Terms that should NOT be translated or modified:
// Centronic PLUS, Centronic, Centronic PLUS, Becker, Becker Antriebe, Becker Antriebe GmbH, Timecontrol, XCF, Evo
// Modifications to these terms will result in a rejected translation.

// Keep the formatting and placeholders e.g. %s. Missing placeholders will result in a rejected translation.
// Keep language codes in square brackets, e.g. [de]. Removing or Omitting them will result in a rejected translation.
// If there's already a translation, keep it as is, as it has been reviewed and approved. Altering it will result in a rejected translation.
// Do not add additional text or markdown formatting to your response, as this breaks the translation. Doing so will result in a rejected translation.
// Keep newline formatting with "\\n" in tact. Do not remove or add new line breaks. Doing so will result in a rejected translation.

// # Examples
// $examples

// # Additional hints (german:english)
// AUF:UP
// ZU:DOWN

// # Form
// $form

// ''';

// String getExamples ()
//   =>createExample("Durch das Löschen der Funkzuordnung werden alle Einstellungen zum gewählten Funksystem zurückgesetzt! Eingelernte Handsender verlieren dadurch die Funktion und müssen neu verbunden werden. Sind Sie sicher dass das Funksystem zurückgesetzt werden soll?", translationsByLocale)
//   + createExample("Schaltaktor (Impuls)", translationsByLocale)
//   + createExample("Das gewählte Centronic PLUS Gerät ist bereits Teil einer anderen Installation. Wie möchten Sie fortfahren?", translationsByLocale)
//   + createExample("Sende Paket %s von %s", translationsByLocale)
//   + createExample("Fahren Sie Ihre Jalousie in die obere Endlage und drücken Sie anschließend auf \"Weiter\".", translationsByLocale)
//   + createExample("Markise", translationsByLocale)
//   + createExample("Rollladen / Screen", translationsByLocale)
//   + createExample("Beschattungsautomatik", translationsByLocale);

// final shortLocales = ["de", "en", "fr", "es", "it", "nl", "cs", "pl", "sv", "tr", "hu"];
// final locales      = ["english", "czech", "turkish", "spanish", "french", "italian", "dutch", "polish", "swedish", "hungarian"];



// final openAIClient = OpenAIClient(
//   baseUrl: OAI_BASE_URL,
//   apiKey: API_KEY,
// );

// Map<String, Map<String, String>> translationsByLocale = {};

// void main (List<String> arguments) async {
//   final argParser = ArgParser()
//     ..addOption('pot', abbr: 'p', defaultsTo: '../translations/pot/messages.pot', help: 'Path to the extracted pot file.')
//     ..addOption('out', abbr: 'o', defaultsTo: '../translations/out', help: 'Output path where the translated JSON files are placed.')
//     ..addOption('ref', abbr: 'r', defaultsTo: '../translations/ref', help: 'JSON reference / existing translations.')
//     ..addOption('translate', abbr: 't', help: 'EXCLUSIVE! No other options handled! Translate only the given string.')
//     ..addOption('batch', abbr: 'b', defaultsTo: '1', help: 'Number of messages that are processed at once by the AI.')
//     ..addOption('q', abbr: 'q', help: 'Create the translator prompt for the given string.')
//     ..addFlag('help', abbr: 'h', negatable: false, help: 'Displays this help information.');

//   final args = argParser.parse(arguments);
//   String  potFilePath     = args['pot'];
//   String  outFolderPath   = args['out'];
//   String  referencePath   = args['ref'];
//   String? translateString = args['translate'];
//   String? promptString    = args['q'];
//   final   batchSize       = int.parse(args['batch']);
//   final   help            = args['help'] as bool;

//   if (help) {
//     print(argParser.usage);
//     exit(0);
//   }

//   if (outFolderPath.isNotEmpty && !path.isAbsolute(outFolderPath)) {
//     outFolderPath = path.absolute(outFolderPath);
//   }

//   if (referencePath.isNotEmpty && !path.isAbsolute(referencePath)) {
//     referencePath = path.absolute(referencePath);
//   }

//   if (potFilePath.isNotEmpty && !path.isAbsolute(potFilePath)) {
//     potFilePath = path.absolute(potFilePath);
//   }

//   translationsByLocale = loadTranslations(referencePath);
  
//   final msgids = extractMsgids(potFilePath);
//   final existingDeTranslations = translationsByLocale['en'] ?? {};
//   final untranslatedMsgids = msgids.where((msgid) => !existingDeTranslations.containsKey(msgid)).toList();
//   final exampleTranslations = getExamples();

//   if (promptString != null) {
//     final prompt = getPrompt(locales.join(", "), exampleTranslations, promptString);
//     print(prompt);
//     exit(0);
//   }

//   if (translateString != null) {
//     await translateMessages([translateString], locales, exampleTranslations);
//     exit(0);
//   }
  
//   for (var i = 0; i < untranslatedMsgids.length; i += batchSize) {
//     final batch = untranslatedMsgids.skip(i).take(batchSize).toList();
//     try {
//       final translatedMessages = await translateMessages(batch, locales, exampleTranslations);
//       if (translatedMessages == null) {
//         return;
//       }
//       save(translatedMessages, outFolderPath);
//       print('\n---\n');
//       print('Translated ${i + batch.length} of ${untranslatedMsgids.length} messages');
//       print('\n---\n');
//     } catch (e) {
//       print("Error: translation for $batch failed $e");
//     }
//   }
  
//   print("Translation run complete!");
// }

// List<String> extractMsgids(String filePath) {
//   try {
//     final file = File(filePath);
//     final lines = file.readAsLinesSync();
//     final msgids = <String>[];
//     final buffer = StringBuffer();

//     for (var line in lines) {
//       if (line.startsWith('msgid')) {
//         if (buffer.isNotEmpty) {
//           msgids.add(buffer.toString());
//           buffer.clear();
//         }
//         buffer.write(line.substring(7, line.length - 1));
//       } else if (line.startsWith('"')) {
//         buffer.write(line.substring(1, line.length - 1));
//       }
//     }

//     if (buffer.isNotEmpty) {
//       msgids.add(buffer.toString());
//     }

//     return msgids;
//   } catch(e) {
//     print('Error parsing pot file from path: $filePath\n$e');
//     exit(1);
//   }
// }

// Map<String, Map<String, String>> loadTranslations(String folderPath) {
//   final translations = <String, Map<String, String>>{};

//   for (var locale in shortLocales) {
//     final filePath = '$folderPath/$locale.json';
//     final file = File(filePath);
//     if (file.existsSync()) {
//       final jsonContent = file.readAsStringSync();
//       translations[locale] = Map<String, String>.from(json.decode(jsonContent));
//     }
//   }

//   return translations;
// }

// String createExample(String msgid, Map<String, Map<String, String>> translations) {
//   final examples = <String>[];

//   examples.add('\n## Input:');
//   examples.add('$msgid');

//   examples.add('\n## Output:');
//   for (var locale in translations.keys) {
//     final translation = translations[locale]?[msgid];
//     if (translation != null) {
//       examples.add('[$locale] $translation');
//     }
//   }

//   return examples.join('\n') + '\n';
// }

// Future<String?> translateMessages(List<String> messages, List<String> locales, String exampleTranslations) async {
//   print("# Translating ${messages.length} messages \n* ${messages.join("\n* ")}");
//   print('\n---\n');

//   List<String> form = [];
//   messages.forEach((message) {
//     form.add('[de] ${message}');
//     shortLocales.forEach((locale) {
//       if (locale != 'de') {
//         form.add('[${locale}]');
//       }
//     });
//     form.add('\n---\n');
//   });

//   final prompt = getPrompt(locales.join(", "), exampleTranslations, form.join('\n'));

  

//   final res = await openAIClient.createChatCompletionStream(
//     request: CreateChatCompletionRequest(
//       model: ChatCompletionModel.modelId(COMPLETION_MODEL),
//       messages: [
//         ChatCompletionMessage.user(
//           content: ChatCompletionUserMessageContent.string(prompt),
//         ),
//       ],
//       temperature: 0,
//     ),
//   );

//   final buffer = StringBuffer();
//   await stdout.addStream(res.map((choice) {
//     final content = choice.choices.first.delta.content;
//     if (content != null) {
//       buffer.write(content);
//       return utf8.encode(content);
//     }
//     return [];
//   }));

//   return buffer.toString();
// }

// void save(String result, String outputPath) {
//   final translations = <String, Map<String, String>>{};

//   final sections = result.split('\n---\n');
//   for (var section in sections) {
//     final lines = section.trim().split('\n');
//     if (lines.isEmpty) continue;

//     Map<String, String> tx = {};

//     for (var line in lines) {
//       final localeMatch = RegExp(r'\[(\w+)\]').firstMatch(line);
//       if (localeMatch != null) {
//         final locale = localeMatch.group(1);
//         final translation = line.substring(localeMatch.end).trim();
//         tx[locale!] = translation;
//       }
//     }

//     if(tx['de'] != null) {
//       final msgid = tx['de']!;
//       for(final translation in tx.entries) {
//         if(translations[msgid] == null) {
//           translations[msgid] = {};
//         }
//         translations[msgid]![translation.key] = translation.value;
//       }
//     }
//   }

//   final scriptDir = File(Platform.script.toFilePath()).parent.path;
//   for (var locale in shortLocales) {
//     final filePath = outputPath.isNotEmpty ? '$outputPath/$locale.json' : '$scriptDir/$locale.json';
//     final file = File(filePath);
//     Map<String, String> localeTranslations = {};
//     if (file.existsSync()) {
//       final jsonContent = file.readAsStringSync();
//       localeTranslations = Map<String, String>.from(json.decode(jsonContent));
//     }

//     translations.forEach((key, value) {
//       if (value.containsKey(locale)) {
//         localeTranslations[key] = value[locale]!;
//       }
//     });

//     final encoder = JsonEncoder.withIndent('  ');
//     file.writeAsStringSync(encoder.convert(localeTranslations));
//   }
// }
