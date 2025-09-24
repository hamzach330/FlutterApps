part of '../module.dart';

class ClockView extends StatefulWidget {
  final TCClockParam clock;
  final Function () onDelete;
  final Function (int day) toggleDay;
  final Function (int) toggleAction;
  final TCOperationModeType type;
  final String title;
  final Function (TCClockParam clock, int index) toggleClockMode;
  final Function() onToggleBlockTime;
  final Function() getTime;
  final bool amTimeDisplay;
  final Function(int astroOffset) setAstroOffset;
  final TextEditingController _astroOffset = TextEditingController(text: "0");

  ClockView({
    super.key,
    required this.clock,
    required this.onDelete,
    required this.toggleDay,
    required this.toggleAction,
    required this.toggleClockMode,
    required this.type,
    required this.title,
    required this.onToggleBlockTime,
    required this.amTimeDisplay,
    required this.getTime,
    required this.setAstroOffset,
  }) {
    _astroOffset.text = clock.astroOffset.toString();
  }

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  

  @override
  Widget build(BuildContext context) {
    dev.log("Clock.build ${widget.clock.action} ${widget.clock.moveTo}");
    dev.log("Clock.build ${widget.clock.overlaps}");
    final theme = Theme.of(context);
    // final subtitle = theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return UICGridTile(
      elevation: 2,
      borderColor: widget.clock.overlaps
        ? theme.colorScheme.errorVariant.primaryContainer
        : Colors.transparent,
      bodyPadding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace),
      // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
      title: UICGridTileTitle(
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        title: Text(widget.title, style: subtitle?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
      ),
      body: Column(
        children: [
          if(widget.clock.overlaps) Container(
            margin: EdgeInsets.only(top: theme.defaultWhiteSpace),
            padding: EdgeInsets.all(theme.defaultWhiteSpace),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.errorVariant.primaryContainer,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("Es existiert bereits eine Uhr mit dieser Schaltzeit!".i18n,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.errorVariant.primaryContainer)
            )
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text("Tage".i18n, style: subtitle)
            ),
          ),

          Center(
            child: UICToggleButtonList(
              onChanged: widget.toggleDay,
              axis: Axis.horizontal,
              buttons: [
                UICToggleButton(
                  selected: widget.clock.days[0],
                  child: Text("Mo".i18n),
                ),
                UICToggleButton(
                  selected: widget.clock.days[1],
                  child: Text("Di".i18n),
                ),
                UICToggleButton(
                  selected: widget.clock.days[2],
                  child: Text("Mi".i18n),
                ),
                UICToggleButton(
                  selected: widget.clock.days[3],
                  child: Text("Do".i18n),
                ),
                UICToggleButton(
                  selected: widget.clock.days[4],
                  child: Text("Fr".i18n),
                ),
                UICToggleButton(
                  selected: widget.clock.days[5],
                  child: Text("Sa".i18n),
                ),
                UICToggleButton(
                  selected: widget.clock.days[6],
                  child: Text("So".i18n),
                ),
              ],
            ),
          ),
          
          const UICSpacer(2),
          
          Align(
            alignment: Alignment.topLeft,
            child: Text("Aktion".i18n, style: subtitle)
          ),

          const UICSpacer(),
                
          UICToggleButtonList(
            onChanged: widget.toggleAction,
            buttons: [
              UICToggleButton(
                leading: Transform.scale(
                  scale: 1.2,
                  child: const Icon(Icons.change_history_rounded),
                ),
                selected: widget.clock.action == TCClockAction.move && widget.clock.moveTo == 0,
                child: widget.type == TCOperationModeType.Awning
                  ? Text("Schliessen".i18n, textAlign: TextAlign.end)
                  : Text("Auf".i18n, textAlign: TextAlign.end),
              ),
              
              UICToggleButton(
                leading: RotatedBox(
                  quarterTurns: 2,
                  child: Transform.scale(
                    scale: 1.2,
                    child: const Icon(Icons.change_history_rounded),
                  ),
                ),
                selected: widget.clock.action == TCClockAction.move && widget.clock.moveTo == 100,
                child: widget.type == TCOperationModeType.Awning
                  ? Text("Öffnen".i18n, textAlign: TextAlign.end)
                  : Text("Ab".i18n, textAlign: TextAlign.end),
              ),
              
              UICToggleButton(
                leading: const Icon(BeckerIcons.device_shutter),
                selected: widget.clock.action == TCClockAction.move && widget.clock.moveTo != 100 && widget.clock.moveTo != 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if(widget.clock.action != TCClockAction.move || (widget.clock.action == TCClockAction.move && (widget.clock.moveTo == 100 || widget.clock.moveTo == 0))) Text("Position".i18n, textAlign: TextAlign.end),
                
                    if(widget.clock.action == TCClockAction.move && widget.clock.moveTo != 100 && widget.clock.moveTo != 0) Row(
                      children: [
                        Text("Position".i18n, textAlign: TextAlign.end),
                        const Text(" - "),
                        Text("${widget.clock.moveTo}%", textAlign: TextAlign.end),
                      ]
                    ),

                    if(widget.type == TCOperationModeType.Venetian && widget.clock.action == TCClockAction.move && widget.clock.moveTo != 100 && widget.clock.moveTo != 0) const UICSpacer(),
                
                    if(widget.type == TCOperationModeType.Venetian && widget.clock.action == TCClockAction.move && widget.clock.moveTo != 100 && widget.clock.moveTo != 0) Row(
                      children: [
                        Text("Wendung".i18n, textAlign: TextAlign.end),
                        const Text(" - "),
                        Text("${widget.clock.moveSlatTo}%", textAlign: TextAlign.end),
                      ]
                    ),
                
                  ],
                ),
              ),
              
              UICToggleButton(
                leading: const Icon(BeckerIcons.two),
                selected: widget.clock.action == TCClockAction.pos2,
                child: Text("ZP2 / Beschattungsposition".i18n, textAlign: TextAlign.end),
              ),
              
              UICToggleButton(
                leading: const Icon(BeckerIcons.one),
                selected: widget.clock.action == TCClockAction.pos1,
                child: Text("ZP1 / Lüftungsposition".i18n, textAlign: TextAlign.end),
              ),
              
              UICToggleButton(
                leading: const Icon(Icons.beach_access_rounded),
                selected: widget.clock.action == TCClockAction.automaticOn,
                child: Text("Sonnenschutzautomatik ein".i18n, textAlign: TextAlign.end),
              ),

              UICToggleButton(
                leading: const Icon(Icons.sunny),
                selected: widget.clock.action == TCClockAction.automaticOff,
                child: Text("Sonnenschutzautomatik aus".i18n, textAlign: TextAlign.end),
              ),
            ],
          ),

          const UICSpacer(2),

          Align(
            alignment: Alignment.topLeft,
            child: Text("Wenn".i18n, style: subtitle)
          ),

          const UICSpacer(),
          
          UICToggleButtonList(
            onChanged: (index) {
              widget.toggleClockMode(widget.clock, index);
            },
            buttons: [
              UICToggleButton(
                leading: const Icon(Icons.access_time_filled_rounded),
                selected: widget.clock.clockType[0],
                child: Text("Uhrzeit".i18n, textAlign: TextAlign.end),
              ),
               UICToggleButton(
                leading: Transform.scale(
                  scale: 1.2, // Leicht vergrößert für bessere Darstellung
                  child: const Icon(Icons.wb_twilight),
                ),
                selected: widget.clock.clockType[1],
                child: Text("Astro Abends".i18n, textAlign: TextAlign.end),
              ),
               UICToggleButton(
                leading: Transform.scale(
                  scale: 1.2, // Leicht vergrößert für bessere Darstellung
                  child: const Icon(Icons.wb_twighlight),
                ),
                selected: widget.clock.clockType[2],
                child: Text("Astro Morgens".i18n, textAlign: TextAlign.end),
              ),
              // UICToggleButton(
              //   leading: ImageIcon(
              //     const AssetImage("assets/icons/sunrise.png"),
              //     size: 32,
              //     color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
              //   ),
              //   selected: widget.clock.clockType[1],
              //   child: Text("Astro Abends".i18n, textAlign: TextAlign.end),
              // ),
              // UICToggleButton(
              //   leading: ImageIcon(
              //     const AssetImage("assets/icons/sunrise.png"),
              //     size: 32,
              //     color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
              //   ),
              //   selected: widget.clock.clockType[2],
              //   child: Text("Astro Morgens".i18n, textAlign: TextAlign.end),
              // ),
            ],
          ),
                
          if (widget.clock.isAstroControlled) Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Verschiebung".i18n),
                  Text("(+/- 60 Minuten)".i18n),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.remove),
                      color: Colors.blue,
                      onPressed: () {
                        widget.setAstroOffset(min(120, max(-120, int.parse(widget._astroOffset.text))) - 1);
                      }
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: UICTextInput(
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false
                      ),
                      onEditingComplete: () {
                        widget.setAstroOffset(min(120, max(-120, int.parse(widget._astroOffset.text))));
                      },
                      controller: widget._astroOffset,
                    )
                  ),
                  // Text("${astroOffset}", style: TextStyle(fontSize: 20)),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      iconSize: 32,
                      color: Colors.blue,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        widget.setAstroOffset(min(120, max(-120, int.parse(widget._astroOffset.text))) + 1);
                      }
                    ),
                  ),
                ],
              ),
            ],
          ),
                
          if(widget.clock.isAstroControlled) const UICSpacer(),
                
          if(widget.clock.isAstroControlled) Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sperrzeit".i18n),
                
              UICSwitch(
                value: widget.clock.blockTimeActive,
                onChanged: widget.onToggleBlockTime
              ),
            ],
          ),
                
          if((!widget.clock.isAstroControlled) || (!widget.clock.isMidnight)) const UICSpacer(),
          
          if((!widget.clock.isAstroControlled) || (!widget.clock.isMidnight)) const Divider(),

          if((!widget.clock.isAstroControlled) || (!widget.clock.isMidnight)) const UICSpacer(),
          if((!widget.clock.isAstroControlled) || (!widget.clock.isMidnight)) UICTextButton(
            padding: EdgeInsets.all(theme.defaultWhiteSpace * 2),
            textStyle: theme.textTheme.titleLarge,
            onPressed: widget.getTime,
            // trailing: const Icon(Icons.access_time_filled_rounded, size: 42),
            trailing: const Icon(Icons.watch_later_rounded, size: 42),
            text: widget.amTimeDisplay ?
              "%s".i18n.fill([DateFormat("hh:mm a").format(widget.clock.time)]) :
              "%s Uhr".i18n.fill([DateFormat.Hm().format(widget.clock.time)]),

          ),
                
          const UICSpacer(2),

          UICElevatedButton(
            style: UICColorScheme.error,
            onPressed: widget.onDelete,
            leading: const Icon(Icons.highlight_remove_rounded),
            child: Text("Schaltzeit Löschen".i18n),
          ),
          
          const UICSpacer(2),
        ]
      ),
    );

  }
}
