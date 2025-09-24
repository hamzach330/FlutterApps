part of 'module.dart';

class CCSettings extends StatefulWidget {
  static const path = '${CPHome.path}/settings';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: const CCSettings(),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: CCSettings(),
    ),
  );

  static go (BuildContext context) {
    UICScaffold.of(context).hideSecondaryBody();
    context.go(path);
  }

  static RemoteCC11Info? getOtaForCC11 (BuildContext context) {
    final ota = context.read<OtauInfoProvider>();
    final cp = context.read<CentronicPlus>();

    final updateFile = ota.localInfo?.cc11Files?.where((update) {
      if(cp.version < update.version) {
        return true;
      }

      if(cp.version != update.version) {
        if(cp.version > (update.version ?? Version(0,0,0))) {
          return true;
        }
      }

      return false;
    }).toList();

    return updateFile?.firstOrNull;
  }

  const CCSettings({
    super.key,
  });

  @override
  State<CCSettings> createState() => _CCSettingsState();
}

class _CCSettingsState extends State<CCSettings> {
  late final CentronicPlus cp = context.read<CentronicPlus>();
  late final CCEleven cc = context.read<CCEleven>();

  final nameController = TextEditingController();
  bool nameError = false;
  int? ledIntensity;

  Widget _buildStatRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    try {
      nameController.text = await cc.getDeviceName() ?? "Unbenannt".i18n;
      setState(() {});
    } catch(_) {/* pass */}

    ledIntensity = await cc.getLedIntensity();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setName() {
    final name = nameController.text.trim();
    if (name.isNotEmpty) {
      cc.setDeviceName(name);
    }
  }

  void _checkName(String v) {
    setState(() {
      try {
        Mutators.fromUtf8String(nameController.text, 32);
        nameError = false;
      } catch (e) {
        nameError = true;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = cc.store.getStorageStats();
    final otaAvailable = CCSettings.getOtaForCC11(context);

    return UICPage(
      slivers: [
        UICPinnedHeader(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UICTitle("System".i18n),
            ],
          ),
        ),

        UICConstrainedSliverList(
          maxWidth: 400,
          children: [
            if(otaAvailable != null) UICGridTile(
              collapsed: false,
              collapsible: true,
              borderWidth: 0,
              borderColor: Colors.transparent,
              elevation: 2,
              title: UICGridTileTitle(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
                title: Text("Update %s verfügbar".i18n.fill([otaAvailable.version?.toString() ?? ""])),
              ),
              body: Padding(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Verbesserte Bluetooth-Stabilität".i18n, style: theme.textTheme.bodySmall),
                    Text("• Schnellere Reaktionszeit bei Sprachbefehlen".i18n, style: theme.textTheme.bodySmall),
                    Text("• Neues Energiespar-Feature hinzugefügt".i18n, style: theme.textTheme.bodySmall),
                    Text("• Kleinere UI-Optimierungen in der App".i18n, style: theme.textTheme.bodySmall),
                    Text("• Diverse Bugfixes und Performance-Verbesserungen".i18n, style: theme.textTheme.bodySmall),
                    const UICSpacer(2),
                    Center(
                      child: UICElevatedButton(
                        style: UICColorScheme.success,
                        onPressed: () {},
                        child: Text("Jetzt aktualisieren".i18n),
                      ),
                    )
                  ],
                ),
              ),
            ),

            if(otaAvailable != null) const UICSpacer(),

            UICGridTile(
              collapsed: false,
              collapsible: true,
              borderWidth: 0,
              borderColor: Colors.transparent,
              elevation: 2,
              title: UICGridTileTitle(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
                title: Text("Name".i18n),
              ),
              body: Padding(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                child: Row(
                  children: [
                    Expanded(
                      child: UICTextInput(
                        maxLength: 32,
                        controller: nameController,
                        invalid: nameError,
                        readonly: false,
                        isDense: false,
                        hintText: "Name".i18n,
                        label: "Name".i18n,
                        onChanged: (v) {
                          _checkName(nameController.text);
                        },
                        onEditingComplete: () {
                          _checkName(nameController.text);
                          if (!nameError) {
                            nameController.text = nameController.text.trim();
                          }
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                    const UICSpacer(),
                
                    UICGridTileAction(
                      onPressed: () async {
                        _setName();
                      },
                      style: UICColorScheme.success,
                      child: const Icon(Icons.save_rounded)
                    ),
                  if(nameError) Text("Der Name darf maximal 21 Zeichen lang sein".i18n),
                  ],
                ),
              ),
            ),

            const UICSpacer(),

            UICGridTile(
              collapsed: true,
              collapsible: true,
              borderWidth: 0,
              borderColor: Colors.transparent,
              elevation: 2,
              title: UICGridTileTitle(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
                title: Text("Tastenbelegung".i18n),
              ),
              body: Padding(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CPChannelSelector(
                        repeat: false,
                        segment: 0,
                        gradient: List.generate(
                          14,
                          (i) => HSVColor.fromAHSV(
                          1.0,
                          (i * 360 / 14) % 360,
                          0.8,
                          0.9,
                          ).toColor(),
                        ),
                      ),
                  
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OptionRow<String>(
                            selectedValue: "Auf",
                            options: const [
                              OptionItem(value: "Auf", label: "Auf"),
                              OptionItem(value: "Stop", label: "Stop"),
                              OptionItem(value: "Ab", label: "Ab"),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                              }
                            },
                          ),
                      
                          OptionRow<String>(
                            selectedValue: "Stop",
                            options: const [
                              OptionItem(value: "Auf", label: "Auf"),
                              OptionItem(value: "Stop", label: "Stop"),
                              OptionItem(value: "Ab", label: "Ab"),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                              }
                            },
                          ),
                          
                          OptionRow<String>(
                            selectedValue: "Ab",
                            options: const [
                              OptionItem(value: "Auf", label: "Auf"),
                              OptionItem(value: "Stop", label: "Stop"),
                              OptionItem(value: "Ab", label: "Ab"),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const UICSpacer(),

            UICGridTile(
              collapsed: true,
              collapsible: true,
              borderWidth: 0,
              borderColor: Colors.transparent,
              elevation: 2,
              title: UICGridTileTitle(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
                title: Text("Beleuchtung".i18n),
              ),
              body: Padding(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow("Helligkeit:".i18n, "${((ledIntensity ?? 0) / 255 * 100).toInt()}%"),
                    Row(
                      children: [
                        const Text("0%"),
                        Flexible(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackShape: EdgeToEdgeTrackShape(),
                            ),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: ledIntensity != null ? (ledIntensity! / 255 * 100) : 0,
                              onChanged: (v) {
                                ledIntensity = (v / 100 * 255).toInt();
                                // position = v;
                                setState(() {});
                              },
                              onChangeEnd: (v) {
                                unawaited(cc.setLedIntensity(ledIntensity ?? 0));
                              },
                            ),
                          ),
                        ),
                        const Text("100%"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const UICSpacer(),

            UICGridTile(
              collapsed: true,
              collapsible: true,
              borderWidth: 0,
              borderColor: Colors.transparent,
              elevation: 2,
              title: UICGridTileTitle(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
                title: Text("Geräte-Informationen".i18n),
              ),
              body: Padding(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow("Teilnehmer einer Installation:".i18n, cp.coupled == true ? "Ja".i18n : "Nein".i18n),
                    _buildStatRow("MAC-ID:".i18n, cp.mac ?? ""),
                    _buildStatRow("Installations-ID:".i18n, cp.pan),
                    _buildStatRow("Firmware:".i18n, "${cp.version}"),
                    Consumer<UICPackageInfoProvider>(
                      builder: (context, packageInfo, _) => _buildStatRow("App-Version:".i18n, packageInfo.version?.version ?? ""),
                    ),
                    _buildStatRow("Bekannte Geräte:".i18n, "${cp.getOwnNodes().length}"),
                    _buildStatRow("Speicher belegt".i18n, "${stats['utilization']}"),
                    const UICSpacer(2),

                    Center(
                      child: UICElevatedButton(
                        style: UICColorScheme.error,
                        onPressed: () async {
                          final navigator = GoRouter.of(context);
                          final messenger = UICMessenger.of(context);
                      
                          final answer = await messenger.alert(UICSimpleConfirmationAlert(
                            title: "Gerätespeicher zurücksetzen".i18n,
                            child: Text("Alle Daten werden gelöscht und die Verbindung wird getrennt.\nFortfahren?".i18n),
                          ));
                      
                          if(answer == true) {
                            await cc.store.clearAllData();
                            cc.endpoint.close();
                            navigator.go("/");
                          }
                        },
                        child: Text("Gerätespeicher zurücksetzen".i18n),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }
}

class OptionItem<T> {
  final T value;
  final String label;

  const OptionItem({
    required this.value,
    required this.label,
  });
}

class OptionRow<T> extends StatelessWidget {
  final T selectedValue;
  final List<OptionItem<T>> options;
  final ValueChanged<T?> onChanged;
  final double? width;

  const OptionRow({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: options.map((OptionItem<T> option) {
          return DropdownMenuItem<T>(
            value: option.value,
            child: Text(
              option.label,
              style: theme.textTheme.bodyMedium,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        dropdownColor: theme.colorScheme.surfaceContainerHighest,
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: 200,
      ),
    );
  }
}
