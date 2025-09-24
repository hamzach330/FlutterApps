part of hydrogen_flutter_examples;

class HashMulti extends StatefulWidget {
  final int size;
  const HashMulti({super.key, this.size = 1000000});

  @override
  State<HashMulti> createState() => _HashMultiState();
}

class _HashMultiState extends State<HashMulti> {
  List<int>? hashResult;
  Duration elapsed = Duration.zero;

  TextEditingController keyController     = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  /// This computes a fixed-length fingerprint for an arbitrary long list of strings.
  /// 
  /// Sample use cases:
  /// * File integrity checking
  /// * Creating unique identifiers to index arbitrary long data.
  void getHash({
    required String context,
    required String key,
    required List<String> chunks
  }) async {
    Stopwatch stopwatch = Stopwatch()..start();

    hashResult = await compute((params) {
      final pContext  = params.$1.toNativeUtf8().cast<ffi.Char>();            // copy memory and get pointer to context, needs free
      final pKey      = params.$2.toNativeUtf8().cast<ffi.Uint8>();           // copy memory and get pointer to key, needs free
      final pState    = calloc<hydrogen.hydro_hash_state>();                  // alloc hydro_hash_state, needs free
      final pHash     = calloc<ffi.Uint8>(hydrogen.hydro_hash_BYTES);         // alloc hash of hydro_hash_BYTES size, needs free

      hydrogen.bindings.hydro_hash_init(pState, pContext, pKey);

      for(final chunk in params.$3) {
        final pChunk = ffi.Pointer<ffi.Void>.fromAddress(chunk.toNativeUtf8().address);
        hydrogen.bindings.hydro_hash_update(pState, pChunk, chunk.length);
        calloc.free(pChunk);
      }
      hydrogen.bindings.hydro_hash_final(pState, pHash, hydrogen.hydro_hash_BYTES);

      /// Copy data to a new dart list
      final result = pHash.asTypedList(hydrogen.hydro_hash_BYTES).toList();
      /// Free other resources
      malloc.free(pContext);
      malloc.free(pKey);
      calloc.free(pState);
      calloc.free(pHash);

      return result;
    }, (context, key, chunks));

    elapsed = stopwatch.elapsed;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Key',
    );

    return Column(
      children: [
        Text("Multi-part hash with a key", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),

        SizedBox(
          width: 400,
          child: Column(
            children: [
              TextField(
                controller: contextController,
                decoration: inputDecoration.copyWith(hintText: "Context"),
                keyboardType: TextInputType.multiline,
              ),

              const Br(),

              TextField(
                controller: keyController,
                decoration: inputDecoration.copyWith(hintText: "Key"),
                keyboardType: TextInputType.multiline,
                maxLength: hydrogen.hydro_hash_KEYBYTES,
                maxLines: null,
              ),

              const Br(),

              TextField(
                controller: messageController,
                decoration: inputDecoration.copyWith(hintText: "Message to hash (Line break = new chunk)"),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
        ),
        
        const Br(),

        ElevatedButton(
          onPressed: () => getHash(
            chunks: messageController.text.split("\n"),
            context: contextController.text,
            key: keyController.text
          ),
          child: const Text("Run")
        ),

        if(hashResult != null) const Br(),
        if(hashResult != null) Text("Hash $hashResult generated (${elapsed.inMilliseconds}ms)"),
      ]
    );
  }
}