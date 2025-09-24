part of '../module.dart';

class WizardStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const WizardStepper({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps + 1,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentStep ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}