part of '../module.dart';

class TCAutomatic extends StatefulWidget {
  const TCAutomatic({super.key});

  @override
  State<TCAutomatic> createState() => _TCAutomaticState();
}

class _TCAutomaticState extends State<TCAutomatic> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Timecontrol>(
      builder: (context, timecontrol, _) {
        return SizedBox(
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                child: Container(
                  color: Colors.black.withAlpha((255 * .5).toInt()),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TCAutomaticButton(
                        active: timecontrol.operationMode.automatic,
                        icon: BeckerIcons.clock,
                        onPressed: () async {
                          timecontrol.operationMode.automatic = !(timecontrol.operationMode.automatic);

                          await timecontrol.setOperationMode();
                          setState(() {});
                        }
                      ),
                      
                      const VerticalDivider(
                        indent: 30,
                        endIndent: 30,
                        color: Colors.white
                      ),
        
                      TCAutomaticButton(
                        active: timecontrol.operationMode.automaticSensor,
                        icon: BeckerIcons.weather_sun,
                        onPressed: () async {
                          timecontrol.operationMode.automaticSensor = !(timecontrol.operationMode.automaticSensor);
                          await timecontrol.setOperationMode();
                          setState(() {});
                        }
                      ),
                    ],
                  )
                )
              )
            ],
          ),
        );
      }
    );
  }
}

class TCAutomaticButton extends StatelessWidget {
  final IconData icon;
  final Function () onPressed;
  final bool active;

  const TCAutomaticButton({
    super.key, 
    required this.icon,
    required this.onPressed,
    required this.active
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? backgroundColor;
    Color? splashColor;
    Color? highlightColor;

    if(active) {
      backgroundColor = Colors.green.withAlpha(120);
      splashColor = Colors.green.shade200.withAlpha(150);
      highlightColor = Colors.green.withAlpha(120);
    } else {
      backgroundColor = Colors.black.withAlpha(70);
      splashColor = theme.colorScheme.primaryContainer;
      highlightColor = theme.colorScheme.surfaceTint;
    }

    return ClipOval(
      child: Material(
        color: backgroundColor, // button color
        child: InkWell(
          focusColor: theme.colorScheme.primary,
          hoverColor: theme.colorScheme.primary,
          splashColor: splashColor,
          highlightColor: highlightColor,
          onTap: onPressed,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon)
          ),
        ),
      ),
    );
  }
}
