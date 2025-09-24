part of ui_common;

class DefaultMessageWidget extends StatelessWidget {
  final String message;
  final Color? surfaceColor;
  final Color? onSurfaceColor;

  const DefaultMessageWidget({
    required this.message,
    this.surfaceColor,
    this.onSurfaceColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: surfaceColor ?? Theme.of(context).colorScheme.primary
      ),
      padding: const EdgeInsets.all(10),
      child: Text(message, style: TextStyle(
        color: onSurfaceColor ?? Theme.of(context).colorScheme.onPrimary
      ))
    );
  }
}

class ErrorMessage extends UICStatusMessage {
  ErrorMessage(String message, {
    super.group,
    super.timeout = const Duration(seconds: 3)
  }) : super(builder:(context)=>_builder(context, message));

  static _builder (BuildContext context, String message) {
    return DefaultMessageWidget(
      surfaceColor: Theme.of(context).colorScheme.error,
      onSurfaceColor: Theme.of(context).colorScheme.onError,
      message: message,
    );
  }
}

class InfoMessage extends UICStatusMessage {
  InfoMessage(String message, {
    super.group,
    super.timeout = const Duration(seconds: 3)
  }) : super(builder:(context)=>_builder(context, message));

  static _builder (BuildContext context, String message) {
    return DefaultMessageWidget(
      message: message,
    );
  }
}

class WarningMessage extends UICStatusMessage {
  WarningMessage(String message, {
    super.group,
    super.timeout = const Duration(seconds: 3)
  }) : super(builder:(context)=>_builder(context, message));

  static _builder (BuildContext context, String message) {
    return DefaultMessageWidget(
      surfaceColor: Theme.of(context).colorScheme.warnVariant.surface,
      onSurfaceColor: Theme.of(context).colorScheme.warnVariant.onSurface,
      message: message,
    );
  }
}

class SuccessMessage extends UICStatusMessage {
  SuccessMessage(String message, {
    super.group,
    super.timeout = const Duration(seconds: 3)
  }) : super(builder:(context)=>_builder(context, message));

  static _builder (BuildContext context, String message) {
    return DefaultMessageWidget(
      surfaceColor: Theme.of(context).colorScheme.successVariant.primary,
      onSurfaceColor: Theme.of(context).colorScheme.successVariant.onPrimary,
      message: message,
    );
  }
}




