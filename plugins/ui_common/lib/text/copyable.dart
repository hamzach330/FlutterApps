part of ui_common;

class UICCopyableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final String? value;
  
  const UICCopyableText({
    super.key, 
    required this.text,
    this.style,
    this.value
  });

  @override
  Widget build(BuildContext context) {
    final statusMessenger = UICMessenger.of(context);
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value ?? text));
        statusMessenger.addMessage(InfoMessage("Text in Zwischenablage kopiert".i18n));
      },
      child: Text(text, style: style)
    );
  }
}
