library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:centronic_plus_protocol/centronic_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';
import '../cc_eleven.dart';

part 'binary_store.dart';
part 'cpnode_binary.dart';
part 'group_binary.dart';
part 'storage_cache.dart';
part 'storage_header.dart';
part 'storage_lock.dart';
part 'string_binary.dart';
part 'table_index.dart';


enum TableEntryType {
  none(0),      // free
  cpNode(1),    // Centronic Plus Node
  cNode(2),     // Reserved for C Node
  group(3),     // Group entry
  string(4);    // String entry
  
  const TableEntryType(this.value);
  final int value;
  
  static TableEntryType fromValue(int value) {
    switch (value) {
      case 0: return TableEntryType.none;
      case 1: return TableEntryType.cpNode;
      case 2: return TableEntryType.cNode;
      case 3: return TableEntryType.group;
      case 4: return TableEntryType.string;
      default: throw ArgumentError('Unknown table entry type: $value');
    }
  }
}
