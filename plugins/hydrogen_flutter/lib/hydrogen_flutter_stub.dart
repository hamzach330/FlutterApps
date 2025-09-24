import 'dart:ffi';
import 'dart:io';

import 'hydrogen_flutter_bindings_generated.dart';
export 'hydrogen_flutter_bindings_generated.dart';

/// Library name used to load the lib objects
const String _libName = 'hydrogen_flutter';

/// The dynamic library in which the symbols for [HydrogenFlutterBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  } else if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  } else {
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }
}();

/// The bindings to the native functions in [_dylib].
HydrogenFlutterBindings bindings = HydrogenFlutterBindings(_dylib);
