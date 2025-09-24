part of hydrogen_flutter_examples;

class SignKeyPair {
  final String pk;
  final String sk;
  SignKeyPair({required this.pk, required this.sk});
}

class SignKey extends StatefulWidget {
  const SignKey({super.key});

  @override
  State<SignKey> createState() => _SignKeyState();
}

class _SignKeyState extends State<SignKey> {
  SignKeyPair? result;
  Duration elapsed = Duration.zero;

  SignKeyPair? result2;
  Duration elapsed2 = Duration.zero;

  signKeygen() async {
    Stopwatch stopwatch = Stopwatch()..start();
    result = await compute((_) {
      final kp = calloc<hydrogen.hydro_sign_keypair>();
      hydrogen.bindings.hydro_sign_keygen(kp);

      final result = SignKeyPair(
        pk: base64.encode([
          for(int i = 0; i < hydrogen.hydro_sign_PUBLICKEYBYTES; i++)
            kp.ref.pk[i]
        ]),
        sk: base64.encode([
          for(int i = 0; i < hydrogen.hydro_sign_SECRETKEYBYTES; i++)
            kp.ref.sk[i]
        ])
      );

      calloc.free(kp);

      return result;
    }, null);
    elapsed = stopwatch.elapsed;
    setState(() { });
  }

  signKeygen2() async {
    Stopwatch stopwatch = Stopwatch()..start();
    result2 = await compute((_) {
      final kp = calloc<hydrogen.hydro_sign_keypair>();
      hydrogen.bindings.hydro_sign_keygen(kp);

      final result = SignKeyPair(
        pk: base64.encode(kp.cast<ffi.Uint8>().asTypedList(hydrogen.hydro_sign_PUBLICKEYBYTES).toList()),
        sk: base64.encode(ffi.Pointer<ffi.Uint8>.fromAddress(kp.address + hydrogen.hydro_sign_PUBLICKEYBYTES)
          .asTypedList(hydrogen.hydro_sign_SECRETKEYBYTES)
          .toList()
        )
      );

      calloc.free(kp);

      return result;
    }, null);
    elapsed2 = stopwatch.elapsed;
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Sign key async (Array iteration)", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),
        
        ElevatedButton(
          onPressed: signKeygen,
          child: const Text("Run")
        ),

        if(result != null) const Br(),
        if(result != null) Text("SK: ${result?.sk}"),
        if(result != null) Text("PK: ${result?.pk}"),
        if(result != null) Text("(${elapsed.inMilliseconds}ms)"),
        
        const Br(),

        Text("Sign key async (Pointer arythmetic)", style: Theme.of(context).textTheme.headlineSmall),
        
        const Br(),
        
        ElevatedButton(
          onPressed: signKeygen2,
          child: const Text("Run")
        ),

        if(result2 != null) const Br(),
        if(result2 != null) Text("SK: ${result2?.sk}"),
        if(result2 != null) Text("PK: ${result2?.pk}"),
        if(result2 != null) Text("(${elapsed2.inMilliseconds}ms)"),
        
        const Br(),
      ]
    );
  }
}
