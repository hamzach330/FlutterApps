part of evo_protocol;

/// A simple endpoint implementation for tunneling the evo
/// async protocol through centronic plus sendEvoCommand
/// requests
class CPEvoTunnel extends MTEndpoint<String?> {
  final Future<List<int>?> Function(List<int>) _write;

  CPEvoTunnel({
    required Future<List<int>?> Function(List<int>) write,
  }) : _write = write, super(info: null, name: "evo", protocolName: "");
  
  @override
  Future<void> write(List<int> data) async {
    final res = await _write(data);
    protocol?.read(res ?? []);
  }
}
