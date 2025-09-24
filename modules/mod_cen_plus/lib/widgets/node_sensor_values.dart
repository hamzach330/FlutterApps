part of '../module.dart';

class SensorValuesView extends StatelessWidget {
  const SensorValuesView({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CentronicPlusNode>(
      builder: (context, node, _) {

        if(node.analogValues == null) {
          return Text("Es wurden noch keine Werte gelesen. Bitte haben Sie einen Moment Geduld".i18n, textAlign: TextAlign.center,);
        }

        return GridView.count(
          primary: false,
          padding: const EdgeInsets.all(0),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 1,
          shrinkWrap: true,
          children: [
            if(node.analogValues?.values['sun'] != null) UICSmallTile(
              image: "assets/images/sensor/sun.jpg",
              name: "Sonne".i18n,
              value: node.analogValues?.values['sun']
            ),

            if(node.analogValues?.values['wind'] != null) UICSmallTile(
              image: "assets/images/sensor/wind.jpg",
              name: "Wind".i18n,
              value:  node.analogValues?.values['wind']
            ),

            if(node.analogValues?.values['rain'] != null) UICSmallTile(
              image: "assets/images/sensor/rain.jpg",
              value: "${node.analogValues?.values['rain']}".i18n
            ),

            if(node.analogValues?.values['temp'] != null) UICSmallTile(
              image: "assets/images/sensor/temp.jpg",
              name: "Temperatur".i18n,
              value: node.analogValues?.values['temp']
            ),

            if(node.analogValues?.values['tempOut'] != null) UICSmallTile(
              image: "assets/images/sensor/temp.jpg",
              name: "Temperatur".i18n,
              value: node.analogValues?.values['tempOut']
            ),

            if(node.analogValues?.values['dawn'] != null) UICSmallTile(
              image: "assets/images/sensor/dawn.jpg",
              name: "Dämmerung".i18n,
              value: node.analogValues?.values['dawn']
            ),

            if(node.analogValues?.values['battery'] != null) UICSmallTile(
              image: "assets/images/sensor/battery.jpg",
              name: "Batterie".i18n,
              value: node.analogValues?.values['battery']
            ),
          ],
        );
      }
    );
  }
}

