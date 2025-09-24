part of hydrogen_flutter_examples;

class RandomBuf extends StatefulWidget {
  final int size;
  const RandomBuf({super.key, this.size = 1000000});

  @override
  State<RandomBuf> createState() => _RandomBufState();
}

class _RandomBufState extends State<RandomBuf> {
  List<int>? randomBuf;
  Duration elapsed = Duration.zero;

  /// Get List<int> of [widget.size] random numbers
  /// Example async function using arena allocator
  /// ```
  /// final asyncResult = await hydro.getRandomBuf(10);
  /// ```
  void getRandomBuf() async {
    Stopwatch stopwatch = Stopwatch()..start();

    randomBuf = await compute((size) {
      final tmp     = calloc<ffi.Uint8>(size);

      hydrogen.bindings.hydro_random_buf(tmp.cast<ffi.Void>(), size);
      final result = tmp.asTypedList(size).toList();

      calloc.free(tmp);
      
      return result;
    }, widget.size);

    elapsed = stopwatch.elapsed;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Random buffer async (${widget.size} byte)", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),
        
        ElevatedButton(
          onPressed: getRandomBuf,
          child: const Text("Run")
        ),

        if(randomBuf != null) const Br(),
        if(randomBuf != null) Text("${randomBuf?.length} generated (${elapsed.inMilliseconds}ms)"),
      ]
    );
  }
}