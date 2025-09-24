part of ui_common;

class UICNavigationInterceptor extends StatefulWidget {
  final UICAlert<bool> alert;
  final Widget child;
  final bool enabled;

  UICNavigationInterceptor({
    required this.alert,
    required this.child,
    this.enabled = false
  });

  @override
  State<UICNavigationInterceptor> createState() => UICNavigationInterceptorState(enabled: enabled);

  static UICNavigationInterceptorState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<UICNavigationInterceptorState>();
  }
}

class UICNavigationInterceptorState extends State<UICNavigationInterceptor> {
  late final _messenger = UICMessenger.of(context);

  Function()? onGrant;
  Function()? onDecline;
  bool? _enabled;

  UICNavigationInterceptorState({
    bool? enabled
  }) : _enabled = enabled;

  bool get enabled => _enabled ?? false;

  void enable () {
    _enabled = true;
  }

  void disable () {
    _enabled = false;
  }

  Future<bool> intercept () async {
    if(_enabled != true) {
      return true;
    } else {
      final answer = await _messenger.alert(widget.alert);
      if(answer == true) {
        await onGrant?.call();
        return true;
      } else {
        await onDecline?.call();
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
