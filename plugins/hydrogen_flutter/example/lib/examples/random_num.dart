part of hydrogen_flutter_examples;

class RandomNum extends StatefulWidget {
  const RandomNum({super.key});

  @override
  State<RandomNum> createState() => _RandomNumState();
}

class _RandomNumState extends State<RandomNum> {
  int? resultSync;
  int? resultAsync;
  Duration elapsedSync = Duration.zero;
  Duration elapsedAsync = Duration.zero;

  /// Example sync getter
  /// ```
  /// final syncResult = randomU32();
  /// ```
  void randomU32 () {
    Stopwatch stopwatch = Stopwatch()..start();
    resultSync = hydrogen.bindings.hydro_random_u32();
    elapsedSync = stopwatch.elapsed;
    setState(() {});
  }

  /// Example async getter
  /// ```
  /// final asyncResult = await randomU32Async();
  /// ```
  randomU32Async() async {
    Stopwatch stopwatch = Stopwatch()..start();
    resultAsync = await compute((_) => hydrogen.bindings.hydro_random_u32(), null);
    elapsedAsync = stopwatch.elapsed;
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Random uint32 async", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),
        
        ElevatedButton(
          onPressed: randomU32Async,
          child: const Text("Run")
        ),

        if(resultAsync != null) const Br(),
        if(resultAsync != null) Text("$resultAsync (${elapsedAsync.inMilliseconds}ms)"),
        
        const Br(),

        Text("Random uint32 sync", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),
        
        ElevatedButton(
          onPressed: randomU32,
          child: const Text("Run")
        ),

        if(resultSync != null) const Br(),
        if(resultSync != null) Text("$resultSync (${elapsedSync.inMilliseconds}ms)"),
      ]
    );
  }
}
