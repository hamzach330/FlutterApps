part of "../module.dart";

class CCElevenClock extends StatefulWidget {
  static const path = "${CCElevenHome.path}/clock/:index";

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) {
      final index = int.parse(state.pathParameters["index"] ?? "0");
      final clock = state.extra as CCElevenTimer?;
      return CustomTransitionPage(
        key: ValueKey("${CCElevenHome.path}/clock/$index"),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        child: CCElevenClock(
          clock: clock!,
        ),
      );
    }
  );

  static go (BuildContext context, int index, CCElevenTimer clock) {
    UICScaffold.of(context).showSecondaryBody();
    context.go("${CCElevenHome.path}/clock/$index", extra: clock);
  }

  final CCElevenTimer clock;
  final TextEditingController _astroOffset = TextEditingController(text: "0");

  CCElevenClock({
    super.key,
    required this.clock,
  }) {
    _astroOffset.text = clock.offset.toString();
  }

  @override
  State<CCElevenClock> createState() => _CCElevenClockState();
}

class _CCElevenClockState extends State<CCElevenClock> {
  final nameController = TextEditingController();
  bool invalidName = false;

  late final CentronicPlus cp = context.read<CentronicPlus>();
  late final CCEleven cc = context.read<CCEleven>();
  late final store = cc.store;
  
  bool amTimeDisplay = false;
  List<CentronicPlusNode> selectedNodes = [];

  // Alle verfügbaren Aktionen basierend auf verfügbaren Features
  List<CPAvailableCommands> availableCommands = [];
  
  @override
  void initState() {
    super.initState();
    widget._astroOffset.text = widget.clock.offset.toString();
    final mask = widget.clock.command.cpDevices;
    
    selectedNodes = cp.getNodesFrom64BitMask(mask);
    nameController.text = widget.clock.name == "" ? "Unbenannte Uhr".i18n : widget.clock.name;
    availableCommands = cc.getSharedCommands(selectedNodes);
  }

  void _checkName(String v) {
    setState(() {
      try {
        Mutators.fromUtf8String(nameController.text, 32);
        invalidName = false;
      } catch (e) {
        invalidName = true;
      }
    });
  }

  Future<void> save() async {
    final messenger = UICMessenger.of(context);
    final bitmask = cp.getPage64FromGroupIds(selectedNodes.map((node) => node.groupId).toList());
    widget.clock.name = nameController.text.trim();
    dev.log("Selected nodes bitmask: $bitmask", name: "CCElevenClock.save");

    final barrier = await messenger.createBarrier(
      title: "Speichern".i18n,
      child: Text("Bitte warten...".i18n)
    );

    if(bitmask.equals(List.filled(8, 0))) {
      barrier?.remove();
      messenger.alert(UICSimpleAlert(
        title: "Keine Geräte ausgewählt".i18n,
        child: Text("Bitte wählen Sie mindestens ein Gerät aus.".i18n),
      ));
    } else {
      widget.clock.command.cpDevices = bitmask;
      widget.clock.appId = widget.clock.index ?? 0;
      await cc.setTimers([widget.clock]);
      await cc.saveTimers();
      barrier?.remove();
      messenger.alert(UICSimpleAlert(
        title: "Einstellungen gespeichert".i18n,
        child: Text("Die Einstellungen wurden erfolgreich gespeichert.".i18n),
      ));
    }
  }

  void toggleDay(int day) {
    widget.clock.toggleDay(day);
    setState(() {});
  }

  void getTime () async {
    final messenger = UICMessenger.of(context);
    final time = await messenger.selectTime(DateTime.now());

    if (time != null) {
      widget.clock.setTime(time.hour, time.minute);
      setState(() {});
    }
  }

  void toggleBlockTime() {
    if(widget.clock.blockTimeActive) {
      widget.clock.setTime(0, 0);
    } else {
      final now = DateTime.now();
      widget.clock.setTime(now.hour, now.minute);
    }

    setState(() {});
  }

  void onDelete() async {
    final messenger = UICMessenger.of(context);
    final result = await messenger.alert(UICSimpleQuestionAlert(
      title: "Uhr löschen".i18n,
      child: Text("Möchten Sie diese Uhr wirklich löschen?".i18n),
    ));

    if (result == true) {
      widget.clock.clear();
      await cc.setTimers([widget.clock]);
      await cc.saveTimers();
      messenger.alert(UICSimpleAlert(
        title: "Einstellungen gespeichert".i18n,
        child: Text("Die Einstellungen wurden erfolgreich gespeichert.".i18n),
      ));
    }
  }

  void toggleAction (int actionIndex) async {
    if (actionIndex < availableCommands.length) {
      widget.clock.command.cmd = availableCommands[actionIndex];
      dev.log("Selected command: ${widget.clock.command.cmd.name}", name: "_CCElevenClockState.toggleAction");

      if(widget.clock.command.cmd == CPAvailableCommands.moveTo) {
        final slatSupported = selectedNodes.any((node) => node.features.contains(CPFeatures.moveToSlat));

        final value = await UICMessenger.of(context).alert(CCElevenSliderAlert(
          position: widget.clock.command.lift.toDouble(),
          slat: !slatSupported ? null : widget.clock.command.tilt.toDouble(),
        ));

        widget.clock.command.lift = value?.$1?.toInt() ?? 0;
        widget.clock.command.tilt = value?.$2?.toInt() ?? 0;
      }

      setState(() {});
    }
  }

  IconData _getCommandIcon(CPAvailableCommands cmd) {
    switch (cmd) {
      case CPAvailableCommands.up:
        return Icons.keyboard_arrow_up;
      case CPAvailableCommands.down:
        return Icons.keyboard_arrow_down;
      case CPAvailableCommands.pos1:
        return Icons.looks_one;
      case CPAvailableCommands.pos2:
        return Icons.looks_two;
      case CPAvailableCommands.sunProtectionOn:
        return Icons.wb_sunny;
      case CPAvailableCommands.sunProtectionOff:
        return Icons.wb_sunny_outlined;
      case CPAvailableCommands.moveTo:
        return Icons.my_location;
      case CPAvailableCommands.stop:
        return Icons.stop;
      case CPAvailableCommands.on:
        return Icons.power;
      case CPAvailableCommands.off:
        return Icons.power_off;
    }
  }

  String _getCommandDisplayName(CPAvailableCommands cmd) {
    switch (cmd) {
      case CPAvailableCommands.up:
        return "Auf".i18n;
      case CPAvailableCommands.down:
        return "Ab".i18n;
      case CPAvailableCommands.pos1:
        return "Position 1".i18n;
      case CPAvailableCommands.pos2:
        return "Position 2".i18n;
      case CPAvailableCommands.sunProtectionOn:
        return "Sonnenschutz Ein".i18n;
      case CPAvailableCommands.sunProtectionOff:
        return "Sonnenschutz Aus".i18n;
      case CPAvailableCommands.moveTo:
        return "Fahre zu".i18n;
      case CPAvailableCommands.stop:
        return "Stop".i18n;
      case CPAvailableCommands.on:
        return "Ein".i18n;
      case CPAvailableCommands.off:
        return "Aus".i18n;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return UICPage(
      //pop: () => UICScaffold.of(context).hideSecondaryBody(),
      slivers: [
        UICPinnedHeader(
          height: 70.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            tooltip: "Zurück".i18n,
            onPressed: () {
              UICScaffold.of(context).hideSecondaryBody();
            },
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
              backgroundColor: theme.colorScheme.successVariant.primaryContainer,
              foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
              elevation: 2,
            ),
            onPressed: save,
            child: Row(
              children: [
                Text("Speichern".i18n),
                const UICSpacer(),
                Icon(Icons.save_rounded, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
              ],
            ),
          ),
        ),
        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            UICTextInput(
              maxLength: 32,
              controller: nameController,
              invalid: invalidName,
              readonly: false,
              isDense: false,
              hintText: "Name".i18n,
              label: "Name".i18n,
              onChanged: (v) {
                _checkName(nameController.text);
              },
              onEditingComplete: () {
                _checkName(nameController.text);
                if (!invalidName) {
                  nameController.text = nameController.text.trim();
                }
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),

            UICSpacer(2),

            Row(
              children: [
                Text("Empfänger".i18n, style: subtitle),
                const Spacer(),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    elevation: 2,
                  ),
                  onPressed: () async {
                    cp.unselectNodes();
                    selectedNodes = await UICMessenger.of(context).alert(CCElevenSelectDevices(
                      centronicPlus: cp,
                      selection: selectedNodes,
                    )) ?? [];
                    availableCommands = cc.getSharedCommands(selectedNodes);
                    setState((){});
                  },
                  child: Row(
                    children: [
                      Text("Auswahl".i18n),
                      const UICSpacer(),
                      Icon(Icons.list_alt, size: 16, color: theme.colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),

              ],
            ),

            UICSpacer(),
            
            Column(
              spacing: theme.defaultWhiteSpace,
              children: [
                for(final node in selectedNodes) Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.defaultWhiteSpace * 1.5),
                    border: Border.all(color: theme.colorScheme.secondary, width: 1.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(theme.defaultWhiteSpace),
                    child: Row(
                      children: [
                        node.getIcon(theme.colorScheme.secondary),
                        const UICSpacer(),
                        Text(node.name ?? node.mac),
                      ]
                    ),
                  ),
                ),
              ],
            ),

            UICSpacer(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Tage".i18n, style: subtitle)
              ),
            ),
      
            Center(
              child: UICToggleButtonList(
                onChanged: toggleDay,
                axis: Axis.horizontal,
                buttons: [
                  UICToggleButton(
                    selected: widget.clock.weekdays[0],
                    child: Text("Mo".i18n),
                  ),
                  UICToggleButton(
                    selected: widget.clock.weekdays[1],
                    child: Text("Di".i18n),
                  ),
                  UICToggleButton(
                    selected: widget.clock.weekdays[2],
                    child: Text("Mi".i18n),
                  ),
                  UICToggleButton(
                    selected: widget.clock.weekdays[3],
                    child: Text("Do".i18n),
                  ),
                  UICToggleButton(
                    selected: widget.clock.weekdays[4],
                    child: Text("Fr".i18n),
                  ),
                  UICToggleButton(
                    selected: widget.clock.weekdays[5],
                    child: Text("Sa".i18n),
                  ),
                  UICToggleButton(
                    selected: widget.clock.weekdays[6],
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

            if(selectedNodes.isEmpty) UICSpacer(),
            if(selectedNodes.isEmpty) Text("Bitte Empfänger / Gruppen auswählen".i18n, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
      
            const UICSpacer(),
                  
            UICToggleButtonList(
              onChanged: toggleAction,
              buttons: [
                for (int i = 0; i < availableCommands.length; i++)
                  UICToggleButton(
                    leading: Icon(_getCommandIcon(availableCommands[i])),
                    selected: widget.clock.command.cmd == availableCommands[i],
                    child: Text(_getCommandDisplayName(availableCommands[i]), textAlign: TextAlign.end),
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
                if(index == 0) {
                  final now = DateTime.now();
                  widget.clock.setTime(now.hour, now.minute);
                }
                widget.clock.toggleMode(index + 1);
                setState(() {});
              },
              buttons: [
                UICToggleButton(
                  leading: const Icon(Icons.access_time_filled_rounded),
                  selected: widget.clock.type.type == CCElevenTimerType.fixedTime,
                  child: Text("Uhrzeit".i18n, textAlign: TextAlign.end),
                ),

                UICToggleButton(
                  leading: Transform.scale(
                    scale: 1.2,
                    child: const Icon(Icons.wb_twighlight),
                  ),
                  selected: widget.clock.type.type == CCElevenTimerType.astroMorning,
                  child: Text("Astro Morgens".i18n, textAlign: TextAlign.end),
                ),

                UICToggleButton(
                  leading: Transform.scale(
                    scale: 1.2,
                    child: const Icon(Icons.wb_twilight),
                  ),
                  selected: widget.clock.type.type == CCElevenTimerType.astroAfternoon,
                  child: Text("Astro Abends".i18n, textAlign: TextAlign.end),
                ),

              ],
            ),

            if (widget.clock.isAstroControlled) const UICSpacer(2),
            
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
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.remove),
                      color: Colors.blue,
                      onPressed: () {
                        try {
                          widget.clock.setOffset(
                            min(120, max(-120, int.parse(widget._astroOffset.text))) - 1
                          );
                          widget._astroOffset.text = widget.clock.offset.toString();
                        } catch (e) {
                          widget._astroOffset.text = widget.clock.offset.toString();
                        }
                        setState(() {});
                      }
                    ),

                    const UICSpacer(),

                    SizedBox(
                      width: 100,
                      child: UICTextInput(
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false
                        ),
                        onEditingComplete: () {
                          try {
                            widget.clock.setOffset(
                              min(120, max(-120, int.parse(widget._astroOffset.text)))
                            );
                            widget._astroOffset.text = widget.clock.offset.toString();
                          } catch (e) {
                            widget._astroOffset.text = widget.clock.offset.toString();
                          }
                          setState(() {});
                        },
                        controller: widget._astroOffset,
                      )
                    ),

                    const UICSpacer(),
                    
                    IconButton(
                      iconSize: 32,
                      color: Colors.blue,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        try {
                          widget.clock.setOffset(min(120, max(-120, int.parse(widget._astroOffset.text))) + 1);
                          widget._astroOffset.text = widget.clock.offset.toString();
                        } catch (e) {
                          widget._astroOffset.text = widget.clock.offset.toString();
                        }
                        setState(() {});
                      }
                    ),
                  ],
                ),
              ],
            ),
                  
            if(widget.clock.isAstroControlled) const UICSpacer(2),
                  
            if(widget.clock.isAstroControlled) Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sperrzeit".i18n),
                UICSwitch(
                  value: widget.clock.blockTimeActive,
                  onChanged: toggleBlockTime
                ),
              ],
            ),

            if(widget.clock.blockTimeActive || !widget.clock.isAstroControlled) const UICSpacer(),
            if(widget.clock.blockTimeActive || !widget.clock.isAstroControlled) UICTextButton(
              padding: EdgeInsets.all(theme.defaultWhiteSpace * 2),
              textStyle: theme.textTheme.titleLarge,
              onPressed: getTime,
              trailing: const Icon(Icons.watch_later_rounded, size: 42),
              text: amTimeDisplay ?
                "%s".i18n.fill([DateFormat("hh:mm a").format(widget.clock.time)]) :
                "%s Uhr".i18n.fill([DateFormat.Hm().format(widget.clock.time)]),
            ),
            
            if(widget.clock.isAstroControlled) const UICSpacer(),

            const UICSpacer(4),
      
            Center(
              child: UICElevatedButton(
                style: UICColorScheme.error,
                onPressed: onDelete,
                leading: const Icon(Icons.remove_circle_outline_rounded),
                child: Text("Schaltzeit Löschen".i18n),
              ),
            ),
            
            const UICSpacer(2),
          ]
        ),
      ]
    );
  }
}
