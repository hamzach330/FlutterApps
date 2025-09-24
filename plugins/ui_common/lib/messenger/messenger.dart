part of ui_common;

class UICStatusMessengerGroup {
  int maxSize;
  
  UICStatusMessengerGroup({
    this.maxSize = 1
  });
}

class UICStatusMessage {
  Widget Function(BuildContext, ) builder;
  Completer? _completer;
  final Duration? timeout;
  UICStatusMessengerGroup? group;

  UICStatusMessage({
    required this.builder,
    this.timeout,
    this.group
  }) {
    if(timeout != null) {
      _completer = Completer();
      if(timeout != Duration.zero) {
        Timer(timeout!, () => _completer!.complete());
      }
    }
  }
}

class _UICStatusMessenger extends StatefulWidget {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  _UICStatusMessenger({required key}): super(key: key);

  @override
  createState() => _UICStatusMessengerState();
}

class _UICStatusMessengerState extends State<_UICStatusMessenger> {
  final List<UICStatusMessage> _messages = [];

  @override
  initState() {
    super.initState();
  }

  /// Insert a message
  addMessage(UICStatusMessage message) {
    setState(() {
      _checkGroup(message);
      widget._listKey.currentState?.insertItem(_messages.length);
      _messages.add(message);
      message._completer?.future.then((value) => removeMessage(message));
    });
  }

  OverlayEntry createBarrier(String title, Widget child, bool abortable, Function()? onAbort) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      maintainState: true,
      opaque: false,
      builder: (context) {
        return Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Theme.of(context).platform == TargetPlatform.macOS || Theme.of(context).platform == TargetPlatform.iOS
          ? _UICCupertinoAlert(
            alert: UICBarrierAlert(
              child: child,
              title: title,
              abortable: abortable,
              entry: entry,
              onAbort: onAbort
            ),
          )
          : _UICMaterialAlert(
            alert: UICBarrierAlert(
              child: child,
              title: title,
              abortable: abortable,
              entry: entry,
              onAbort: onAbort
            ),
          ),
        );
      },
    );

    UICAppState._rootNavigatorKey.currentState?.overlay?.insert(entry);

    return entry;
  }

  /// Remove this message
  removeMessage(UICStatusMessage message) {
    _removeMessage(message);
    _messages.remove(message);
  }

  /// Remove all messages
  clear() {
    for(final message in _messages) {
      _removeMessage(message);
    }
    _messages.clear();
  }

  /// Validate max size of the group, remove oldest entries
  _checkGroup(UICStatusMessage message) {
    if(message.group != null) {
      final groupedItems = _messages.where((m) => m.group == message.group);

      if(groupedItems.length >= message.group!.maxSize) {
        int removeCount = groupedItems.length - (message.group!.maxSize - 1);
        _messages.removeWhere((m) {
          if(m.group == message.group && removeCount > 0) {
            removeCount--;
            _removeMessage(m);
            return true;
          }
          return false;
        });
      }
    }
  }

  /// remove the message only from the AnimatedList
  _removeMessage(UICStatusMessage message) {
    if(_messages.contains(message)) {
      widget._listKey.currentState?.removeItem(
        _messages.indexOf(message),
        (context, animation) => _MessengerItem(
          animation: animation,
          child: message.builder(context),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AnimatedList(
          physics: const NeverScrollableScrollPhysics(),
          key: widget._listKey,
          shrinkWrap: true,
          initialItemCount: _messages.length,
          itemBuilder: (context, index, animation) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 5.0),
              child: _MessengerItem(
                animation: animation,
                child: _messages[index].builder(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MessengerItem extends StatelessWidget {
  const _MessengerItem({
    Key? key,
    required this.animation,
    required this.child
  }): super(key: key);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: ScaleTransition(
        scale: animation,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: child
          ),
        )
      ),
    );
  }
}

class UICMessenger extends StatefulWidget {
  final Widget child;

  const UICMessenger({
    super.key,
    required this.child
  });

  @override
  State<UICMessenger> createState() => UICMessengerState();

  static UICMessengerState of (BuildContext context) {
    final state = context.findAncestorStateOfType<UICMessengerState>();
    if(state == null) {
      throw Exception("UICMessengerState not found");
    }
    return state;
  }
}

class UICMessengerState extends State<UICMessenger> {
  GlobalKey<_UICStatusMessengerState> _statusMessenger = GlobalKey<_UICStatusMessengerState>();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => UICAppState._rootNavigatorKey.currentState?.overlay?.insert(OverlayEntry(
      maintainState: true,
      opaque: false,
      builder: (context) {
        _statusMessenger = GlobalKey<_UICStatusMessengerState>();
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _UICStatusMessenger(
            key: _statusMessenger
          )
        );
      },
    )));
  }

  addMessage(UICStatusMessage message) => _statusMessenger.currentState?.addMessage(message);
  removeMessage(UICStatusMessage message) => _statusMessenger.currentState?.removeMessage(message);
  clear() => _statusMessenger.currentState?.clear();

  Future<OverlayEntry?> createBarrier({
    required String title,
    required Widget child,
    Function()? onAbort,
    bool abortable = false
  }) async {
    final completer = Completer<OverlayEntry?>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete(_statusMessenger.currentState?.createBarrier(title, child, abortable, onAbort));
    });
    return completer.future;
  }

  Future<T?> alert<T> (UICAlert<T> alert) async {
    if(UICAppState._rootNavigatorKey.currentContext == null) {
      return null;
    } else {
      return _uicAlert<T>(alert, UICAppState._rootNavigatorKey.currentContext!);
    }
  }

  Future<TimeOfDay?> selectTime(DateTime initialTime) async {
    if(UICAppState._rootNavigatorKey.currentContext == null) {
      return null;
    } else {
      final platform = Theme.of(UICAppState._rootNavigatorKey.currentContext!).platform;
      if(platform == TargetPlatform.iOS) {
        final result = await _uicAlert<DateTime?>(UICTimePickerAlert(time: initialTime), UICAppState._rootNavigatorKey.currentContext!);
        return result != null ? TimeOfDay.fromDateTime(result) : null;
      } else {
        return await _uicAlert<TimeOfDay?>(UICMaterialTimePickerAlert(time: initialTime), UICAppState._rootNavigatorKey.currentContext!);
      }
    }
  }

  void pop <T>([T? value]) => context.mounted ? UICAppState._rootNavigatorKey.currentState?.pop(value) : null;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

