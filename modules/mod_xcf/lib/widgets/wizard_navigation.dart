part of '../module.dart';

/// FIXME: plugins/ui_common/lib/messenger/setup_runner.dart =))
/// 
class WizardNavigation extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final int currentStep;
  final int totalSteps;

  const WizardNavigation({super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: currentStep > 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        if (currentStep > 0)
          ElevatedButton(
            onPressed: onPrevious,
            child: const Text("Zurück"),
          ),
        if (currentStep < totalSteps)
          ElevatedButton(
            onPressed: onNext,
            child: const Text("Weiter"),
          ),
      ],
    );
  }
}