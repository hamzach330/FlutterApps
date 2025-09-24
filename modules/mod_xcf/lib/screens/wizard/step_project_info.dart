part of '../../module.dart';

class StepProjectInfo extends StatefulWidget {
  final VoidCallback onNext;

  const StepProjectInfo({super.key, required this.onNext});

  @override
  State<StepProjectInfo> createState() => _StepProjectInfoState();
}

class _StepProjectInfoState extends State<StepProjectInfo> {
  bool isComplete = false; // Speichert, ob das Formular vollständig ist

  void handleCompletion() {
    setState(() {
      isComplete = true; // Setzt den Status, wenn das Formular fertig ist
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Projekt-Informationen",
            style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                    child: XCFCompanyForm(
                      onIsComplete: handleCompletion,
                      onIsIncomplete: () {
                        setState(() {
                          isComplete = false;
                        });
                      },
                    ),
                  ),
                )
              ),
          ),
        ),
      ],
    );
  }
}
