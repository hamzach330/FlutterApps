part of 'module.dart';

enum OtauChannel {
  release,
  beta,
  alpha,
}

class OtauInfoProvider extends ChangeNotifier {
  OtauInfoProvider({
    OtauChannel channel = OtauChannel.release,
  }) : _channel = channel;

  OtauChannel _channel;
  OtauChannel get channel => _channel;
  set channel(OtauChannel value) {
    _channel = value;
    remoteInfo = null;
    notifyListeners();
  }
  RemoteVersionsInfo? remoteInfo;
  RemoteVersionsInfo? localInfo;
  UICMessengerState? messenger;

  final domain = "https://otau.becker-antriebe.com";

  String get versionsFile {
    switch(channel) {
      case OtauChannel.release: return "versions";
      case OtauChannel.beta: return "versions_beta";
      case OtauChannel.alpha: return "versions_alpha";
    }
  }

  void init (BuildContext context) {
    messenger = UICMessenger.of(context);
    update();
  }

  Future<void> update () async {
    await getLocalVersions();
    await getRemoteVersions();
    compareVersions();
    notifyListeners();
  }

  List<RemoteOTAUInfo>? getOtaForArticleId (String softwareArticleId) {
    return localInfo?.otaFiles?.where((ota) => ota.articleId == softwareArticleId).toList();
  }



  compareVersions () {
    if(remoteInfo?.lastUpdate == null) {
      return;
    } else if(localInfo?.lastUpdate == null) {
      dev.log("Initialize local files");
      loadContents();
    } else if(remoteInfo!.lastUpdate!.isAfter(localInfo!.lastUpdate!)) {
      dev.log("Update local files");
      loadContents();
    } else {
      dev.log("Local files already up to date: ${remoteInfo?._source}");
      loadContents();
    }
  }

  getLocalVersions () async {
    final directory     = (await getApplicationDocumentsDirectory()).path;
    final localInfoFile = File('$directory/$versionsFile.json');

    if(localInfoFile.existsSync()) {
      localInfo = RemoteVersionsInfo.fromBytes(localInfoFile.readAsBytesSync());
      localInfo = localInfo;
    }
  }

  Future getRemoteVersions () {
    final completer = Completer();
    FileLoader(
      domain: domain,
      path: '$versionsFile.json',
      onError: (status) {
        dev.log('ERROR! HTTP Status: $status');
      },
      onProgress: (total, received) {
        dev.log('$received / $total bytes');
      },
      onComplete: (path, content) {
        readRemoteInfo(path, content);
        if(completer.isCompleted == false) {
          completer.complete();
        }
      }
    );

    return completer.future;
  }

  readRemoteInfo (String path, List<int> content) async {
    remoteInfo = RemoteVersionsInfo.fromBytes(content);
    remoteInfo = remoteInfo;
    if(remoteInfo?.lastUpdate == null) {
      /// the remote version info doesn't contain an update date
      return;
    } else {

    }
  }

  loadContents () async {
    Completer completer;
    Map<String, dynamic> out = {
      "last_checked": DateTime.now().toString(),
      "parser": "1.0.0",
      "centronic_plus_tool": "1.1.4",
      // Added: mirror top-level cc11 list (downloaded below). This preserves JSON shape.
      "cc11": [],
      "centronic_plus": {
        "ota": [],
        "stick": []
      },
      "documents": {
        "installation_manual": {
          "version": "",
          "files": {}
        }
      }
    };

    // Phase 1: OTAU files — download newer/missing and mirror to local JSON
    UICStatusMessage infoMessage = InfoMessage("Firmware-Updates werden geladen...".i18n, timeout: Duration.zero);
    messenger?.addMessage(infoMessage);
    for(final ota in (remoteInfo?.otaFiles ?? <RemoteOTAUInfo>[])) {
      final localOtau = localInfo?.otaFiles?.firstWhereOrNull((o) => o.version == ota.version);
      final needUpdate = ota.isNewerThan(localOtau) || !await ota.exists();
      if(needUpdate) {
        completer = Completer();
        FileLoader(
          domain: domain,
          path: ota.path ?? "",
          onError: (status) {
            dev.log('ERROR! HTTP Status: $status');
            completer.complete();
          },
          onProgress: (total, received) {
            dev.log('$received / $total bytes');
          },
          onComplete: (path, content) {
            dev.log("Read OTAU from: $path");
            completer.complete();
          }
        );
        await completer.future;
      }
      out["centronic_plus"]["ota"].add(ota.toJson());
    }
    messenger?.removeMessage(infoMessage);

    // Phase 2: Stick firmware — download newer/missing and mirror to local JSON
    infoMessage = InfoMessage("Aktualisiere Hilfedateien".i18n, timeout: Duration.zero);
    messenger?.addMessage(infoMessage);
    for(final stick in (remoteInfo?.stickFiles ?? <RemoteStickInfo>[])) {
      final localStick = localInfo?.stickFiles?.firstWhereOrNull((s) => s.version == stick.version);
      final needUpdate = stick.isNewerThan(localStick) || !await stick.exists();
      if(needUpdate) {
        completer = Completer();
        FileLoader(
          domain: domain,
          path: stick.path ?? "",
          onError: (status) {
            dev.log('ERROR! HTTP Status: $status');
            completer.complete();
          },
          onProgress: (total, received) {
            dev.log('$received / $total bytes');
          },
          onComplete: (path, content) {
            dev.log("Read Stick FW from: $path");
            completer.complete();
          }
        );
        await completer.future;
      }
      out["centronic_plus"]["stick"].add(stick.toJson());
    }
    messenger?.removeMessage(infoMessage);

    // Phase 3: CC11 firmware — optional top-level list; cache newer/missing, mirror to local JSON
    infoMessage = InfoMessage("Aktualisiere CC11 Firmware".i18n, timeout: Duration.zero);
    messenger?.addMessage(infoMessage);
    for(final cc11 in (remoteInfo?.cc11Files ?? <RemoteCC11Info>[])) {
      final localCc11 = localInfo?.cc11Files?.firstWhereOrNull((c) => c.version == cc11.version);
      final needUpdate = cc11.isNewerThan(localCc11) || !await cc11.exists();
      if(needUpdate) {
        completer = Completer();
        FileLoader(
          domain: domain,
          path: cc11.path ?? "",
          onError: (status) {
            dev.log('ERROR! HTTP Status: $status');
            completer.complete();
          },
          onProgress: (total, received) {
            dev.log('$received / $total bytes');
          },
          onComplete: (path, content) {
            dev.log("Read CC11 FW from: $path");
            completer.complete();
          }
        );
        await completer.future;
      }
      out["cc11"].add(cc11.toJson());
    }
    messenger?.removeMessage(infoMessage);

    // Phase 4: Manuals — download only current locale when newer/missing
    infoMessage = InfoMessage("Aktualisiere Hilfedateien".i18n, timeout: Duration.zero);
    messenger?.addMessage(infoMessage);
    for(final installationManual in (remoteInfo?.installationManual ?? <RemoteInstallationManualInfo>[])) {
      final localInstallationManual = localInfo?.installationManual
        ?.firstWhereOrNull((m) => m.language == installationManual.language);
      final needUpdate = installationManual.isNewerThan(localInstallationManual)
        || !await installationManual.exists();
        
      if(needUpdate && Localization.locale == installationManual.language) {
        completer = Completer();
        FileLoader(
          domain: domain,
          path: installationManual.path ?? "",
          onError: (status) {
            dev.log('ERROR! HTTP Status: $status');
            completer.complete();
          },
          onProgress: (total, received) {
            dev.log('$received / $total bytes');
          },
          onComplete: (path, content) {
            dev.log("Read installation manual from: $path");
            completer.complete();
          }
        );
        await completer.future;
      }
      out["documents"]["installation_manual"]["files"][installationManual.language!] = installationManual.path;
    }
    messenger?.removeMessage(infoMessage);
    localInfo = remoteInfo;
    
    // final successMessage = SuccessMessage("Alles aktuell!");
    // messenger?.addMessage(successMessage);

    out["documents"]["installation_manual"]["version"] = remoteInfo?.installationManual?.first.version.toString()
      ?? localInfo?.installationManual?.first.version.toString()
      ?? "0.0.0";
    out["last_update"] = remoteInfo?.lastUpdate?.toString() ?? "";
    out["parser"] = "1.0";
    out["centronic_plus_tool"] = "1.1.4";

    final directory = (await getApplicationDocumentsDirectory()).path;
    final file = File('$directory/$versionsFile.json');
    final result = const JsonEncoder.withIndent("  ").convert(out);

    await file.writeAsString(result);
  }
}
