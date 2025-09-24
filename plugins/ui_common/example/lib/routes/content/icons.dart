
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ContentIcons extends StatelessWidget {
  static const route = '/subroute';
  static Widget buildRoute(dynamic params) => const ContentIcons();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const ContentIcons({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Theme.of(context).defaultWhiteSpace, vertical: Theme.of(context).defaultWhiteSpace),
      children: [
        const UICTitle("BeckerIcons"),
        GridView(
          primary: false,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: Theme.of(context).defaultWhiteSpace,
            mainAxisSpacing: Theme.of(context).defaultWhiteSpace,
            childAspectRatio: 3/4,
          ),
          children: const [
            Column(
              children: [
                Icon(BeckerIcons.comfort, size: 32),
                Text("comfort")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.work, size: 32),
                Text("work")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.nodes, size: 32),
                Text("nodes")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.scene_1, size: 32),
                Text("scene_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.eco, size: 32),
                Text("eco")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.dial, size: 32),
                Text("dial")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.space_heater, size: 32),
                Text("space_heater")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.door, size: 32),
                Text("door")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.roof_window, size: 32),
                Text("roof_window")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.receiver, size: 32),
                Text("receiver")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.settings_1, size: 32),
                Text("settings_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.delete, size: 32),
                Text("delete")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.bed_3, size: 32),
                Text("bed_3")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_G, size: 32),
                Text("glyph_G")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x, size: 32),
                Text("weather_x")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.ventilation, size: 32),
                Text("ventilation")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.transceiver, size: 32),
                Text("transceiver")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.undo, size: 32),
                Text("undo")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.delete_bordered, size: 32),
                Text("delete_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.remove_bordered, size: 32),
                Text("remove_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.support, size: 32),
                Text("support")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.medium_house, size: 32),
                Text("medium_house")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_unknown, size: 32),
                Text("weather_unknown")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.settings_2, size: 32),
                Text("settings_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.check, size: 32),
                Text("check")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.info_1, size: 32),
                Text("info_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.one, size: 32),
                Text("one")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_I, size: 32),
                Text("glyph_I")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_H, size: 32),
                Text("glyph_H")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.up_bordered, size: 32),
                Text("up_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_sun, size: 32),
                Text("weather_sun")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.music, size: 32),
                Text("music")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.paint_2, size: 32),
                Text("paint_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.location, size: 32),
                Text("location")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.signal_5, size: 32),
                Text("signal_5")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.value, size: 32),
                Text("value")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.restore, size: 32),
                Text("restore")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_foggy, size: 32),
                Text("weather_foggy")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.down_bordered, size: 32),
                Text("down_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_J, size: 32),
                Text("glyph_J")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.two, size: 32),
                Text("two")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.food, size: 32),
                Text("food")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.couple, size: 32),
                Text("couple")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.three, size: 32),
                Text("three")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_K, size: 32),
                Text("glyph_K")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.stop_bordered_1, size: 32),
                Text("stop_bordered_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_12, size: 32),
                Text("weather_x_12")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.right, size: 32),
                Text("right")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.single, size: 32),
                Text("single")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.network, size: 32),
                Text("network")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.signal_4, size: 32),
                Text("signal_4")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.signal_3, size: 32),
                Text("signal_3")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.speak, size: 32),
                Text("speak")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.down, size: 32),
                Text("down")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_11, size: 32),
                Text("weather_x_11")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_62, size: 32),
                Text("glyph_62")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_L, size: 32),
                Text("glyph_L")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.four, size: 32),
                Text("four")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.tv, size: 32),
                Text("tv")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.wind, size: 32),
                Text("wind")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.room, size: 32),
                Text("room")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.computer, size: 32),
                Text("computer")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.five, size: 32),
                Text("five")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_N, size: 32),
                Text("glyph_N")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_shutter_blinds, size: 32),
                Text("device_shutter_blinds")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.play_bordered, size: 32),
                Text("play_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.small_house, size: 32),
                Text("small_house")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.window_open, size: 32),
                Text("window_open")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.effect, size: 32),
                Text("effect")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.signal_2, size: 32),
                Text("signal_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.signal_1, size: 32),
                Text("signal_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.vacation, size: 32),
                Text("vacation")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.refresh, size: 32),
                Text("refresh")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.think, size: 32),
                Text("think")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.backup_restore, size: 32),
                Text("backup_restore")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.backup_store, size: 32),
                Text("backup_store")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.document, size: 32),
                Text("document")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.becker, size: 32),
                Text("becker")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.magic, size: 32),
                Text("magic")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.settings_3, size: 32),
                Text("settings_3")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.updown, size: 32),
                Text("updown")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.shutter_blinds, size: 32),
                Text("shutter_blinds")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.add_bordered, size: 32),
                Text("add_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.reload, size: 32),
                Text("reload")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.paint_1, size: 32),
                Text("paint_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.info, size: 32),
                Text("info")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.settings_4, size: 32),
                Text("settings_4")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_V, size: 32),
                Text("glyph_V")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_W, size: 32),
                Text("glyph_W")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_X, size: 32),
                Text("glyph_X")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_Z, size: 32),
                Text("glyph_Z")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_Y, size: 32),
                Text("glyph_Y")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.expand, size: 32),
                Text("expand")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_snow, size: 32),
                Text("weather_snow")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.save, size: 32),
                Text("save")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.manual, size: 32),
                Text("manual")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.stop_bordered, size: 32),
                Text("stop_bordered")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.some, size: 32),
                Text("some")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.up, size: 32),
                Text("up")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.big_house, size: 32),
                Text("big_house")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.favorite, size: 32),
                Text("favorite")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.calendar, size: 32),
                Text("calendar")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.camera, size: 32),
                Text("camera")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.unlock, size: 32),
                Text("unlock")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.lock, size: 32),
                Text("lock")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.radiator, size: 32),
                Text("radiator")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_dark_cloud, size: 32),
                Text("weather_dark_cloud")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_117, size: 32),
                Text("glyph_117")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_shutter, size: 32),
                Text("device_shutter")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_screen, size: 32),
                Text("device_screen")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_awning, size: 32),
                Text("device_awning")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_thermostat, size: 32),
                Text("device_thermostat")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_venetian, size: 32),
                Text("device_venetian")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_switch, size: 32),
                Text("device_switch")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_dimmer_1, size: 32),
                Text("device_dimmer_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_sun_sail, size: 32),
                Text("device_sun_sail")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_1, size: 32),
                Text("weather_x_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_2, size: 32),
                Text("weather_x_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.radio, size: 32),
                Text("radio")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.clock, size: 32),
                Text("clock")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.ventilate, size: 32),
                Text("ventilate")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_dimmer_2, size: 32),
                Text("device_dimmer_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_dimmer_3, size: 32),
                Text("device_dimmer_3")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.water_drop, size: 32),
                Text("water_drop")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_3, size: 32),
                Text("weather_x_3")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_136, size: 32),
                Text("glyph_136")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.power, size: 32),
                Text("power")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.fountain, size: 32),
                Text("fountain")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.device_door, size: 32),
                Text("device_door")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.couch, size: 32),
                Text("couch")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.anti_freeze, size: 32),
                Text("anti_freeze")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.cooking, size: 32),
                Text("cooking")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.shower, size: 32),
                Text("shower")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.baking, size: 32),
                Text("baking")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.stairs, size: 32),
                Text("stairs")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.fishtank, size: 32),
                Text("fishtank")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.sensor_smoke, size: 32),
                Text("sensor_smoke")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.kid_1, size: 32),
                Text("kid_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.kid_2, size: 32),
                Text("kid_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.kid_3, size: 32),
                Text("kid_3")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.bed_1, size: 32),
                Text("bed_1")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.bed_2, size: 32),
                Text("bed_2")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.six, size: 32),
                Text("six")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.seven, size: 32),
                Text("seven")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.eight, size: 32),
                Text("eight")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.nine, size: 32),
                Text("nine")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.zero, size: 32),
                Text("zero")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_A, size: 32),
                Text("glyph_A")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_B, size: 32),
                Text("glyph_B")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_C, size: 32),
                Text("glyph_C")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.some_more, size: 32),
                Text("some_more")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.outside, size: 32),
                Text("outside")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_D, size: 32),
                Text("glyph_D")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_E, size: 32),
                Text("glyph_E")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_F, size: 32),
                Text("glyph_F")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_O, size: 32),
                Text("glyph_O")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_P, size: 32),
                Text("glyph_P")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_Q, size: 32),
                Text("glyph_Q")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_R, size: 32),
                Text("glyph_R")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_S, size: 32),
                Text("glyph_S")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_T, size: 32),
                Text("glyph_T")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_U, size: 32),
                Text("glyph_U")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_174, size: 32),
                Text("glyph_174")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_10, size: 32),
                Text("weather_x_10")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.back, size: 32),
                Text("back")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.stop, size: 32),
                Text("stop")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_8, size: 32),
                Text("weather_x_8")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_9, size: 32),
                Text("weather_x_9")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_6, size: 32),
                Text("weather_x_6")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_13, size: 32),
                Text("weather_x_13")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.thermostat, size: 32),
                Text("thermostat")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.left, size: 32),
                Text("left")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_191, size: 32),
                Text("glyph_191")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.sensor_glass, size: 32),
                Text("sensor_glass")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.internal_object, size: 32),
                Text("internal_object")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.signal, size: 32),
                Text("signal")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.sensor_open, size: 32),
                Text("sensor_open")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.movement, size: 32),
                Text("movement")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.move, size: 32),
                Text("move")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.automation, size: 32),
                Text("automation")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.key, size: 32),
                Text("key")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.visible, size: 32),
                Text("visible")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_203, size: 32),
                Text("glyph_203")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_7, size: 32),
                Text("weather_x_7")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.configure_house, size: 32),
                Text("configure_house")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.weather_x_5, size: 32),
                Text("weather_x_5")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.glyph_M, size: 32),
                Text("glyph_M")
              ]
            ),
            Column(
              children: [
                Icon(BeckerIcons.factory_building, size: 32),
                Text("factory_building")
              ]
            ),
          ]
        ),
      ],
    );
  }
}