part of '../module.dart';

class CPNodeName extends StatefulWidget {
  final CentronicPlusNode node;
  final bool readOnly;
  final bool simpleMode;

  const CPNodeName({super.key, required this.node, this.readOnly = false, this.simpleMode = false});

  @override
  State<CPNodeName> createState() => _CPNodeNameState();
}

class _CPNodeNameState extends State<CPNodeName> {
  final nameController = TextEditingController();
  bool invalidName = false;
  bool hasName = false;
  Completer<bool>? confirmCompleter;
  StreamSubscription? buttonEvents;

  @override
  initState() {
    super.initState();
    nameController.text = widget.node.name ?? "";
    if (widget.node.isBatteryPowered) {
      buttonEvents = widget.node.simpleDigitalEvents.stream.listen(
        _onRemoteButtonPressed,
      );
    }
  }

  void _onRemoteButtonPressed(CPRemoteActivity event) {
    confirmCompleter?.complete(true);
    confirmCompleter = null;
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

  @override
  void didUpdateWidget(covariant CPNodeName oldWidget) {
    super.didUpdateWidget(oldWidget);
    nameController.text = widget.node.name ?? "";
  }

  void _setName() async {
    if (widget.node.isBatteryPowered) {
      confirmCompleter = Completer<bool>();
      OverlayEntry? barrier = await UICMessenger.of(context).createBarrier(
        title: "Warte auf Handsender".i18n,
        abortable: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text("Drücken Sie jetzt eine Taste an Ihrem Handsender".i18n),
        ),
        onAbort: () {
          confirmCompleter?.complete(false);
          confirmCompleter = null;
        },
      );

      final result = await confirmCompleter?.future;
      barrier?.remove();

      if (result == true) {
        widget.node.setName(nameController.text);
      }
    } else {
      widget.node.setName(nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.simpleMode)
                TextField(
                  controller: nameController,
                  maxLength: 32,
                  readOnly: widget.readOnly,
                  textAlign: TextAlign.center,
                  style: widget.node.name?.isEmpty == true 
                    ? theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      )
                    : theme.textTheme.headlineSmall,
                  decoration: InputDecoration(
                    hintText: "Gerätename".i18n,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: "",
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (v) {
                    _checkName(nameController.text);
                  },
                  onEditingComplete: () {
                    _checkName(nameController.text);
                    if (!invalidName) {
                      nameController.text = nameController.text.trim();
                      _setName();
                    }
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                )
              else
                UICTextInput(
                  maxLength: 32,
                  controller: nameController,
                  invalid: invalidName,
                  readonly: widget.readOnly,
                  isDense: false,
                  hintText: "Gerätename".i18n,
                  label: "Gerätename".i18n,
                  onChanged: (v) {
                    _checkName(nameController.text);
                  },
                  onEditingComplete: () {
                    _checkName(nameController.text);
                    if (!invalidName) {
                      nameController.text = nameController.text.trim();
                      _setName();
                    }
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),

              if (invalidName == true && !widget.simpleMode)
                Padding(
                  padding: EdgeInsets.only(top: theme.defaultWhiteSpace / 2),
                  child: Text(
                    "Der Name ist zu lang!".i18n,
                    style: TextStyle(
                      color: theme.colorScheme.errorVariant.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
