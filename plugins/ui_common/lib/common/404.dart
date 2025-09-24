part of ui_common;

class UIC404 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 128, color: Colors.red),
          
          const UICSpacer(5),
      
          Text("Der angegebene Pfad wurde nicht gefunden!".i18n, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red),),
          
          const UICSpacer(10),
      
          Center(
            child: UICElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Zurück".i18n),
            ),
          ),
        ],
      ),
    );
  }
}
