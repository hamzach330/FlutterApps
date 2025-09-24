part of ui_common;

Future<T> popOver<T>({
  required List<Widget> children,
  required BuildContext context,
  required Widget title,
  String buttonText    = 'Ok',
  bool dismissable     = true,
  bool abortable       = false,
  List<Widget> actions = const [],
  bool forceMaterialDesign = true,
  double? maxWidth = 400,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0)
}) async {
  final theme = Theme.of(context);
  final scrollController = ScrollController();
  return await showDialog(
    barrierDismissible: dismissable,
    context: context,
    useRootNavigator: true,
    builder: (overlayContext) {
      return Center(
        child: Theme(
          data: theme.copyWith(
            dialogTheme: theme.dialogTheme.copyWith(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AlertDialog(
              backgroundColor: theme.colorScheme.surface.withAlpha((255 * .8).toInt()),
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              titlePadding: const EdgeInsets.all(10),
              insetPadding: margin,
              clipBehavior: Clip.hardEdge,
              title: title,
              content: SizedBox(
                width: maxWidth,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                ...actions,
                if (abortable == true && actions.isEmpty && !dismissable) UICAlertAction(
                  text: buttonText,
                  onPressed: () => Navigator.of(overlayContext).pop(0)
                )
              ]
            ),
          ),
        ),
      );
    }
  );
}
