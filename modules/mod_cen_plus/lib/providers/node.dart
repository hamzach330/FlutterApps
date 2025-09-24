part of '../module.dart';

extension CPNodeImage on CentronicPlusNode {
  AssetImage getImage() {
    switch(initiator) {
      case CPInitiator.rolloDrive:
        return const AssetImage("assets/images/devices/shutter.jpeg");
      case CPInitiator.actImpulseShutter:
        return const AssetImage("assets/images/devices/shutter.jpeg");
      case CPInitiator.sunDrive:
        return const AssetImage("assets/images/devices/awning.jpeg");
      case CPInitiator.bldc:
        return const AssetImage("assets/images/devices/shutter.jpeg");
      case CPInitiator.actWayLight:
      case CPInitiator.actImpulseLight:
      case CPInitiator.actSwitchDim:
        return const AssetImage("assets/images/devices/dimmer.jpeg");
      case CPInitiator.sunDriveJal:
        return const AssetImage("assets/images/devices/venetian.jpeg");
      case CPInitiator.sunDusk:
        return const AssetImage("assets/images/products/sc631.png");
      case CPInitiator.sunDuskWind:
        return const AssetImage("assets/images/devices/sc911.jpg");
      case CPInitiator.markiSensSec:
        return const AssetImage("assets/images/devices/sc911.jpg");
      case CPInitiator.sunDuskWindHumTempout:
        return const AssetImage("assets/images/devices/sc911.jpg");
      case CPInitiator.sunDriveZip:
        return const AssetImage("assets/images/devices/screen.jpeg");
      case CPInitiator.oneTwo:
        return const AssetImage("assets/images/devices/switch.jpeg");
      case CPInitiator.central0:
        if(manufacturer == 0x02) {
          return const AssetImage("assets/images/products/homee_centronic_plus.png");
        } else {
          return const AssetImage("assets/images/products/usb_centronic_plus.png");
        }
      case CPInitiator.easySwitch:
        return const AssetImage("assets/images/products/ec.png");
      case CPInitiator.marki:
        return const AssetImage("assets/images/products/ec.png");
      default:
        return const AssetImage("assets/images/devices/unknown.jpeg");
    }
  }

  Widget getIcon([Color? color]) {
    switch(initiator) {
      case CPInitiator.rolloDrive:
        return Icon(BeckerIcons.device_shutter, color: color);
      case CPInitiator.sunDrive:
        return Icon(BeckerIcons.device_awning, color: color);
      case CPInitiator.bldc:
        return Icon(BeckerIcons.device_shutter, color: color);
      case CPInitiator.actSwitchDim:
      case CPInitiator.actWayLight:
        return Icon(BeckerIcons.device_dimmer_1, color: color);
      case CPInitiator.sunDriveJal:
        return Icon(BeckerIcons.device_venetian, color: color);
      case CPInitiator.oneTwo:
      case CPInitiator.actImpulseLight:
        return Icon(BeckerIcons.updown, color: color);
      case CPInitiator.sunDusk:
      case CPInitiator.sunDuskWind:
      case CPInitiator.sunDuskTempin:
      case CPInitiator.sunDuskTempout:
      case CPInitiator.sunDuskTempinPpm:
      case CPInitiator.sunDuskWindHumTempout:
        return ImageIcon(AssetImage("assets/images/sensor_control.png"), color: color);
      case CPInitiator.easySwitch:
      case CPInitiator.marki:
        return ImageIcon(AssetImage("assets/images/remote.png"), color: color);
      // case CPInitiator.markiSensSec:
      //   return AssetImage("assets/images/devices/sc911.jpg");
      // case CPInitiator.sunDuskWindHumTempout:
      //   return AssetImage("assets/images/devices/sc911.jpg");
      case CPInitiator.sunDriveZip:
        return Icon(BeckerIcons.device_screen, color: color);
      case CPInitiator.central0:
      case CPInitiator.central1:
      case CPInitiator.central2:
        return Icon(Icons.usb_rounded, color: color);
      default:
        return ImageIcon(AssetImage("assets/images/icon.png"), color: color);
    }
  }

  AssetImage? getProductImage() {
    if(isVarioControl) {
      if (productName?.contains("VC470") == true) {
        return const AssetImage("assets/images/products/vc470.png");
      } else if (productName?.contains("VC420") == true) {
        return const AssetImage("assets/images/products/vc420.png");
      } else if (productName?.contains("VC180") == true) {
        return const AssetImage("assets/images/products/vc180.png");
      } else if (productName?.contains("VC520") == true) {
        return const AssetImage("assets/images/products/vc520.png");
      } else {
        return const AssetImage("assets/images/products/vc420.png");
      }
    } else if(isLightControl) {
      return const AssetImage("assets/images/products/vc420.png");
    } else if(initiator == CPInitiator.sunDuskWindHumTempout || initiator == CPInitiator.markiSensSec) {
      return getImage();
    } else if(isDrive) {
      return const AssetImage("assets/images/products/cxx-drive.png"); 
    }
    return null;
  }
}
