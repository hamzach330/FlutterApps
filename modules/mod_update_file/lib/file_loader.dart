part of 'module.dart';

class FileLoader {
  final String domain;
  final String path;
  final String? directory;
  final Function(int, int) onProgress;
  final Function(String, List<int>) onComplete;
  final Function(int) onError;
  final bool write;

  FileLoader({
    required this.domain,
    required this.path,
    required this.onProgress,
    required this.onComplete,
    required this.onError,
    this.write = true,
    this.directory
  }) {
    _run();
  }

  Future<void> _run() async {
    http.StreamedResponse? response;
    try {
      response = await http.Client()
        .send(http.Request('GET', Uri.parse("$domain/$path")));
    } catch(e) {
      if (kDebugMode) {
        print("Fehler: $e");
      }
    }
    if(response?.statusCode != 200 && response?.statusCode != 304) {
      onError(response?.statusCode ?? -1);
      return;
    }

    final total = response?.contentLength ?? 0;
    final bytes = <int>[];

    response?.stream
      .listen((value) {
        bytes.addAll(value);
        onProgress(total, value.length);
      })
      .onDone(() async {
        if(write == false) {
          onComplete(path, bytes);
          return;
        }
        final d = directory ?? (await getApplicationDocumentsDirectory()).path;
        final file = File('$d/$path');
        if(file.existsSync() == false) {
          file.createSync(recursive: true);
        }
        await file.writeAsBytes(bytes);
        onComplete(file.path, bytes);
      });
  }
}
