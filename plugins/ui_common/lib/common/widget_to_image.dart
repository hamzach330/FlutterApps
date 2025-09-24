part of '../ui_common.dart';

class WidgetToImage extends StatefulWidget {
  final Widget child;
  final void Function(Uint8List imageBytes)? onImageCaptured;

  const WidgetToImage({
    Key? key,
    required this.child,
    this.onImageCaptured,
  }) : super(key: key);

  @override
  State<WidgetToImage> createState() => WidgetToImageState();
}

class WidgetToImageState extends State<WidgetToImage> {
  final GlobalKey _repaintKey = GlobalKey();

  /// Call this to capture the image and return bytes
  Future<Uint8List?> captureImageBytes() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final pixelRatio = View.of(context).devicePixelRatio;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (widget.onImageCaptured != null) {
        widget.onImageCaptured!(pngBytes);
      }

      return pngBytes;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Capture the image and export to a file
  Future<String?> exportImageToFile({String fileName = 'widget_image.png'}) async {
    try {
      Uint8List? pngBytes = await captureImageBytes();
      if (pngBytes == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/rssi_log/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      dev.log('Image exported to: $filePath', name: 'WidgetToImage');

      return filePath;
    } catch (e) {
      debugPrint('Error exporting image to file: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintKey,
      child: widget.child,
    );
  }
}

// Example usage in a page
class ExamplePage extends StatelessWidget {
  final GlobalKey<WidgetToImageState> _widgetToImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Widget to Image')),
      body: Column(
        children: [
          WidgetToImage(
            key: _widgetToImageKey,
            onImageCaptured: (Uint8List imageBytes) {
              print('Image captured: ${imageBytes.length} bytes');
            },
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              child: Center(child: Text('Hello!')),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = await _widgetToImageKey.currentState?.exportImageToFile();
              if (path != null) {
                print('Image saved to: $path');
              }
            },
            child: Text('Export Image to File'),
          ),
        ],
      ),
    );
  }
}
