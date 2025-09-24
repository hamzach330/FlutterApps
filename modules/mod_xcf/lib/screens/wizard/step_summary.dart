part of '../../module.dart';

class StepSummary extends StatelessWidget {
  final VoidCallback onPrevious;

  const StepSummary({super.key, required this.onPrevious});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Zusammenfassung", style: Theme.of(context).textTheme.titleLarge),
        Expanded(
            child: Container(child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const XCFSetupView()),
                );
              },
              child: Text("Fertigstellen"),
            )),
        ),
        WizardNavigation(
          onPrevious: onPrevious,
          currentStep: 3,
          totalSteps: 3,
        ),
      ],
    );
  }
}