part of '../module.dart';

extension CPOtauInfoProvider on OtauInfoProvider{
  RemoteOTAUInfo? getOtaForNode (CentronicPlusNode node) {
    if(node.artId == null && node.initiator != CPInitiator.sunDuskWind) {
      return null;
    }

    final ota = localInfo?.otaFiles?.where((update) {
      if(update.articleId == node.artId) {
        if(node.semVer == null && node.version == null) return false;

        if((node.semVer ?? Version(0,0,0)) < update.version) {
          return true;
        }

        if(update.upgradeRequirements != null && node.semVer != update.version) {
          if((node.semVer ?? Version(0,0,0)) > (update.upgradeRequirements?.minVersion ?? Version(0,0,0))) {
            if((node.semVer ?? Version(0,0,0)) < (update.upgradeRequirements?.maxVersion ?? Version(0,0,0))) {
              return true;
            }
          }
        }
      }

      return false;
    }).toList();

    return ota?.firstOrNull;
  }
}