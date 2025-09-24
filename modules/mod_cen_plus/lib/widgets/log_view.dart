part of '../module.dart';

class CPLog extends StatefulWidget {
  const CPLog({super.key});

  @override
  createState () => _CPLogState();
}

class _CPLogState extends State<CPLog> {
  final ScrollController scrollController = ScrollController();
  late final centronicPlus = Provider.of<CentronicPlus>(context, listen: false);
  TextEditingController rawTelegramController = TextEditingController();
  bool collapsed = true;
  MTMessageInfoInterface? selection;
  String? pre;
  String? current;
  String? post;

  void sendRaw() {
    final message = ascii.encode(rawTelegramController.text.replaceAll(RegExp(r'\s'), ''));
    centronicPlus.endpoint.logMessage(
      message: rawTelegramController.text.replaceAll(RegExp(r'\s'), ''),
      tag: MTLogTags.outgoing
    );
    centronicPlus.endpoint.write([0x02, ...message, 0x03]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(collapsed) selection = null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withAlpha((0.3 * 255).toInt()),
            offset: const Offset(0, 0)
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.data_array_sharp),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("Telegrammdarstellung".i18n, style: theme.textTheme.titleSmall),
                ),
              ),
              if(!collapsed) IconButton(
                onPressed: centronicPlus.endpoint.clearLog,
                icon: const Icon(Icons.delete_forever),
              ),
              if(!collapsed) IconButton(
                onPressed: () async {
                  String? outPath = await FilePicker.platform.saveFile(
                    dialogTitle: 'Funkprotokoll exportieren'.i18n,
                    fileName: 'debug.log',
                  );

                  if (outPath != null) {
                    if(File(outPath).existsSync()) {
                      File(outPath).writeAsStringSync(logData());
                    }
                  }
                },
                icon: const Icon(Icons.save),
              ),
              if(!collapsed) IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: logData()));
                },
                icon: const Icon(Icons.copy_all),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      collapsed = !collapsed;
                    });
                  },
                  icon: Icon(collapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                )
              ),
            ],
          ),
          if(!collapsed) Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: Row(
              children: [

                Expanded(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                    ),
                    child: StreamBuilder<List<MTMessageInfoInterface>>(
                      stream: centronicPlus.endpoint.messageLog.stream,
                      initialData: centronicPlus.endpoint.logData,
                      builder: (context, stream) {
                        if(scrollController.hasClients && selection == null) {
                          // scrollController.jumpTo(0);
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: stream.data?.length ?? 0,
                          reverse: false,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final messageInfo = stream.data!.reversed.toList()[index];

                            if(selection == messageInfo && current != null) {
                              return Row(
                                children: [
                                  Text("[${DateFormat.Hms().format(messageInfo.time)}]${messageInfo.tag} $pre", style: TextStyle(
                                    fontFamily: "SourceCodePro",
                                      color: theme.colorScheme.onSecondary
                                    )
                                  ),
                                  Text(current ?? "", style: const TextStyle(
                                    fontFamily: "SourceCodePro",
                                      color: Colors.red
                                    )
                                  ),
                                  Text(post ?? "", style: TextStyle(
                                    fontFamily: "SourceCodePro",
                                      color: theme.colorScheme.onSecondary
                                    )
                                  ),
                                ],
                              );
                            }

                            return GestureDetector(
                              child: SelectableText("[${DateFormat.Hms().format(messageInfo.time)}]${messageInfo.tag} ${messageInfo.telegram}",
                                onTap: () => setState(() {
                                  pre = null; current = null; post = null;
                                  selection = messageInfo;
                                  messageInfo.byteCounter = 0;
                                }),
                                style: TextStyle(
                                  fontFamily: "SourceCodePro",
                                  color: messageInfo == selection ? theme.colorScheme.onSecondary : theme.colorScheme.onSecondary.withAlpha(155)
                                )
                              ),
                            );
                          } 
                        );
                      }
                    ),
                  ),
                ),
                if(selection != null) SizedBox(
                  width: 400,
                  height: 300,
                  child: ListView(
                    reverse: false,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    children: [
                      if(selection?.name != null) Text(selection!.name!, style: Theme.of(context).textTheme.titleMedium,),
                      ...selection?.chunks?.map((chunk) { 
                        chunk.start = selection!.byteCounter;
                        if(chunk.length == null) {
                          selection!.byteCounter = selection!.telegram.length ~/ 2 - 4;
                          chunk.end = selection!.byteCounter;
                        } else {
                          selection!.byteCounter += chunk.length!;
                          chunk.end = selection!.byteCounter;
                        }
                        return GestureDetector(
                          onTap: () async {
                            current = selection?.telegram.substring((chunk.start ?? 0) * 2, (chunk.end ?? 0) * 2);
                            await Clipboard.setData(ClipboardData(text: current ?? ""));
                          },
                          child: MouseRegion(
                            onExit: (_) {
                              pre = null;
                              current = null;
                              post = null;
                            },
                            onEnter: (_) {
                              selection?.byteCounter = 0;
                              setState(() {
                                try {
                                  pre = selection?.telegram.substring(0, (chunk.start ?? 0) * 2);
                                  current = selection?.telegram.substring((chunk.start ?? 0) * 2, (chunk.end ?? 0) * 2);
                                  post = selection?.telegram.substring((chunk.end ?? 0) * 2, selection?.telegram.length);
                                } catch(e) {
                                  dev.log("$e");
                                }
                              });
                            },
                            child: chunk.name == "valid" ?
                              Text(chunk.value == true
                                ? "VALID VALUES"
                                : "INVALID VALUES",
                                style: TextStyle(
                                  fontFamily: "SourceCodePro",
                                  color: chunk.value ? Colors.green : Colors.red
                                )
                              )
                              : chunk.name == "lenok"
                              ? Text(chunk.value == true
                                ? "VALID LEN"
                                : "INVALID LEN",
                                style: TextStyle(
                                  fontFamily: "SourceCodePro",
                                  color: chunk.value ? Colors.green : Colors.red
                                )
                              ) :
                              Text("[${chunk.length ?? '*'}] ${chunk.name} = ${chunk.value}", style: const TextStyle(fontFamily: "SourceCodePro",)),
                          ),
                        );
                      }).toList() ?? []
                    ],
                  ),
                )
              ],
            ),
          ),
          if(!collapsed) Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(theme.defaultWhiteSpace),
                  child: UICTextInput(
                    fontFamily: "SourceCodePro",
                    hintText: "Telegramm".i18n,
                    controller: rawTelegramController,
                    onEditingComplete: sendRaw
                  ),
                ),
              ),
              UICGridTileAction(
                onPressed: sendRaw,
                child: const Icon(Icons.send),
              ),
              const UICSpacer()
            ]
          ),
        ],
      ),
    );
  }

  String logData() {
    return centronicPlus.endpoint.logData.reversed.map((e) => e.tag == MTLogTags.dropped
      ? "[${DateFormat.Hms().format(e.time)}]${e.tag} ${e.telegram}"
      : "[${DateFormat.Hms().format(e.time)}]${e.tag} ${e.telegram.replaceAllMapped(RegExp(r".{2}"), (match) => "${match.group(0)} ")}"
    ).toList().join("\n");
  }
}
