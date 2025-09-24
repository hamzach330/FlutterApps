part of hydrogen_flutter_examples;

class RandomNumStream extends StatefulWidget {
  final Duration delay;
  const RandomNumStream({super.key, this.delay = const Duration(seconds: 1)});

  @override
  State<RandomNumStream> createState() => _RandomNumStreamState();
}

class _RandomNumStreamState extends State<RandomNumStream> {
  /// Example stream
  /// ```
  /// final stream = await getNRandomU32Stream();
  /// stream.listen(print);
  /// ```
  Stream<int> getNRandomU32Stream () {
    final receivePort = ReceivePort();

    Isolate.spawn((params) async {
      while(true) {
        params.$1.send(hydrogen.bindings.hydro_random_u32());
        await Future.delayed(params.$2);
      }
    }, (receivePort.sendPort, widget.delay));
    
    return receivePort.cast<int>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Random async interval (${widget.delay.inMilliseconds}ms)", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),
        
        StreamBuilder(
          stream: getNRandomU32Stream(),
          builder: (context, stream) {
            if(stream.hasData) {
              return Text("${stream.data}");
            } else {
              return Container();
            }
          }
        ),

      ]
    );
  }
}
