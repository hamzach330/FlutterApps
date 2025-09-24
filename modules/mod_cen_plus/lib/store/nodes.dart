part of '../module.dart';

extension CentronicPlusNodeSQLDB on CentronicPlusNode {
  Future<void> saveToDatabase() async {
    final List<Map<String, dynamic>>? maps = await CPSQLStore.db?.query(
      'nodes',
      where: 'mac = ?',
      whereArgs: [mac],
    );

    if (maps != null && maps.isNotEmpty) {
      await _updateDatabase();
    } else {
      await _insertIntoDatabase();
    }
  }

  Future<int> deleteFromDatabase() async {
    return await CPSQLStore.db?.delete(
          'nodes',
          where: 'mac = ?',
          whereArgs: [mac],
        ) ??
        0;
  }

  Future<void> _insertIntoDatabase() async {
    await CPSQLStore.db?.insert('nodes', {
      'mac': mac,
      'panId': panId,
      'initiator': initiator?.value,
      'groupBits': groupId,
      'coupled': coupled ? 1 : 0,
      'name': name,
      'serial': serial,
      'version': version,
      'manufacturer': manufacturer,
      'semVer': semVer?.toString(),
      'artId': artId,
      'build': build,
      'parentMac': parentMac,
      'waitForRediscovery': waitForRediscovery ? 1 : 0,
      'waitForCouple': waitForCouple ? 1 : 0,
      'sensorLoss': sensorLoss == true ? 1 : 0,
      'macAssignmentActive': macAssignmentActive ? 1 : 0,
      'productName': productName,
      'loading': loading ? 1 : 0,
      'readError': readError ? 1 : 0,
      'statusFlags': Mutators.toHexString(statusFlags.raw),
      'batteryPowered': isBatteryPowered ? 1 : 0,
      'visible': visible ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    dev.log("Inserted node $mac [$panId] into database.", name: 'CentronicPlusDB');
  }

  Future<void> _updateDatabase() async {
    final affected = await CPSQLStore.db?.update(
      'nodes',
      {
        'panId': panId,
        'initiator': initiator?.value,
        'coupled': coupled ? 1 : 0,
        'name': name,
        'groupBits': groupId,
        'serial': serial,
        'version': version,
        'manufacturer': manufacturer,
        'semVer': semVer?.toString(),
        'artId': artId,
        'build': build,
        'parentMac': parentMac,
        'waitForRediscovery': waitForRediscovery ? 1 : 0,
        'waitForCouple': waitForCouple ? 1 : 0,
        'sensorLoss': sensorLoss == true ? 1 : 0,
        'macAssignmentActive': macAssignmentActive ? 1 : 0,
        'productName': productName,
        'loading': loading ? 1 : 0,
        'readError': readError ? 1 : 0,
        'batteryPowered': isBatteryPowered ? 1 : 0,
        'statusFlags': Mutators.toHexString(statusFlags.raw),
        'visible': visible ? 1 : 0,
      },
      where: 'mac = ?',
      whereArgs: [mac],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    dev.log("Updated $affected rows for node $mac in database.", name: 'CentronicPlusDB');
  }

  static CentronicPlusNode fromMap(
    Map<String, dynamic> map,
    CentronicPlus cp,
  ) =>
      CentronicPlusNode(
          mac: map['mac'],
          panId: map['panId'],
          cp: cp, // Assuming `cp` is available in the context
          coupled: map['coupled'] == 1,
          initiator:
              CPInitiator.values
                  .where((v) => v.value == map['initiator'])
                  .firstOrNull ??
              CPInitiator.none,
          parentMac: map['parentMac'],
        )
        ..groupId = map['groupBits'] ?? 0
        ..name = map['name']
        ..serial = map['serial']
        ..version = map['version']
        ..manufacturer = map['manufacturer']
        ..semVer = map['semVer'] != null ? Version.parse(map['semVer']) : null
        ..artId = map['artId']
        ..build = map['build']
        ..productName = map['productName']
        ..statusFlags = StatusFlags(
          raw: Mutators.fromHexString(map['statusFlags'] ?? "0000", 2),
        )
        ..isBatteryPowered = map['batteryPowered'] == 1
        ..visible = map['visible'] == 1
        ..getProductName();
}
