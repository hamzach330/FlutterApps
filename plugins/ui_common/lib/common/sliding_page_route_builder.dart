part of ui_common;

class SlidingPageRouteBuilder extends PageRouteBuilder {
  SlidingPageRouteBuilder({
    required super.pageBuilder,
    super.settings,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child
    ) {
      final pushingNext = secondaryAnimation.status == AnimationStatus.forward;
      final poppingNext = secondaryAnimation.status == AnimationStatus.reverse;
      final pushingOrPoppingNext = pushingNext || poppingNext;
      const curve = Curves.easeInOut;

      final offsetTween = pushingOrPoppingNext
        ? Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(-1.0, 0.0)).chain(CurveTween(curve: curve))
        : Tween<Offset>(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).chain(CurveTween(curve: curve));
      late final Animation<Offset> slidingAnimation = pushingOrPoppingNext
        ? offsetTween.animate(secondaryAnimation)
        : offsetTween.animate(animation);
      return SlideTransition(position: slidingAnimation, child: child);
    },
  );
}