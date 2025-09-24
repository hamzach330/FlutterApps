import 'package:modules_common/modules_common.dart';
import 'package:modules_common/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

part 'provider.dart';
part 'file_loader.dart';
part 'versions_parser.dart';

class OTAUSync extends StatefulWidget {
  const OTAUSync({super.key});

  @override
  createState() => _OTAUSyncState();
}

class _OTAUSyncState extends State<OTAUSync> {
  late final otauProvider = Provider.of<OtauInfoProvider>(context, listen: false);
  late final messenger = UICMessenger.of(context);
  


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: UICElevatedButton(
        onPressed: () async {
          final path = await otauProvider.localInfo?.installationManual?.firstWhereOrNull((info) => info.language == Localization.locale)?.getLocalPath();
          if(path != null) {
            await OpenFilex.open(path);
          }
        },
        leading: const Icon(Icons.picture_as_pdf_rounded),
        child: Text("Monteurhandbuch".i18n),
      ),
    );
  }
}

