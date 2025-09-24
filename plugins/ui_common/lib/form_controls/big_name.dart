part of '../ui_common.dart';

class UICBigName extends StatefulWidget {
  final String initialValue;
  final String placeholder;
  final bool readOnly;
  final Function (String value) onEditingComplete;
  final Function (String value) onChanged;

  const UICBigName({
    super.key, 
    this.readOnly = false, 
    required this.initialValue, 
    required this.placeholder, 
    required this.onEditingComplete,
    required this.onChanged
  });

  @override
  State<UICBigName> createState() => _UICBigNameState();
}

class _UICBigNameState extends State<UICBigName> {
  late final TextEditingController nameController;
  bool invalidName = false;

  @override
  initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant UICBigName oldWidget) {
    super.didUpdateWidget(oldWidget);
    nameController.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: nameController,
      maxLength: 32,
      readOnly: widget.readOnly,
      textAlign: TextAlign.center,
      style: nameController.text.isEmpty == true 
        ? theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
          )
        : theme.textTheme.headlineSmall,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        counterText: "",
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      onChanged: (v) {
        widget.onChanged(nameController.text);
      },
      onEditingComplete: () {
        nameController.text = nameController.text.trim();
        widget.onEditingComplete(nameController.text);
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}