part of '../module.dart';

class CPSQLStore extends CPStore {
  static const String _dbFile = 'cp10.db';
  static Database? db;

  CPSQLStore() {
    initializeTables();
  }

  Future<void> initializeTables() async {
    if(Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final databasesPath = await getApplicationDocumentsDirectory();
      String p = path.join(databasesPath.path, _dbFile);
      CPSQLStore.db = await databaseFactory.openDatabase(p,
        options: OpenDatabaseOptions(
          onCreate: (db, version) => createTable(db, version),
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            await migrateVersion(db, oldVersion, newVersion);
          },
          version: 8
        )
      );
    } else {
      final databasesPath = await getApplicationDocumentsDirectory();
      String p = path.join(databasesPath.path, _dbFile);

      CPSQLStore.db = await openDatabase(p,
        onCreate: (db, version) => createTable(db, version),
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await migrateVersion(db, oldVersion, newVersion);
        },
        version: 8
      );
    }
  }

  Future<void> migrateVersion(Database db, int oldVersion, int newVersion) async {
    // if(oldVersion < 7) {
    //   await db.execute('DROP TABLE IF EXISTS nodes');
    //   await createTable(db, 7);
    // }
    // if(oldVersion < 8) {
    //   await db.execute('ALTER TABLE nodes ADD COLUMN visible INTEGER DEFAULT 0');
    // }
  }

  Future<void> createTable (Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS nodes (
        mac TEXT PRIMARY KEY,
        groupBits INTEGER DEFAULT 0,
        panId TEXT,
        initiator INTEGER,
        coupled INTEGER,
        name TEXT,
        type INTEGER,
        serial TEXT,
        version INTEGER,
        manufacturer INTEGER,
        semVer TEXT,
        artId TEXT,
        build TEXT,
        parentMac TEXT,
        waitForRediscovery INTEGER,
        waitForCouple INTEGER,
        sensorLoss INTEGER,
        macAssignmentActive INTEGER,
        productName TEXT,
        loading INTEGER,
        readError INTEGER,
        statusFlags TEXT,
        batteryPowered INTEGER DEFAULT 0,
        visible INTEGER DEFAULT 0
      )
    ''');
  }

  @override
  Future<CentronicPlusNode?> getNode(String mac, CentronicPlus cp) async {
    final List<Map<String, dynamic>>? maps = await CPSQLStore.db?.query(
      'nodes',
      where: 'mac = ?',
      whereArgs: [mac],
    );

    if (maps != null && maps.isNotEmpty == true) {
      final map = maps.first;
      return CentronicPlusNodeSQLDB.fromMap(map, cp);
    }
    return null;
  }

  @override
  Future<List<CentronicPlusNode>> getAllNodes(CentronicPlus cp) async {
    final List<Map<String, dynamic>>? maps = await CPSQLStore.db?.query(
      'nodes',
      where: 'panId = ?',
      whereArgs: [cp.pan],
    );

    if (maps != null && maps.isNotEmpty) {
      dev.log("Found ${maps.length} nodes in database for PAN ${cp.pan}", name: 'CentronicPlusDB');
      return maps.map((map) => CentronicPlusNodeSQLDB.fromMap(map, cp)).toList();
    }
    return [];
  }

  @override
  Future<bool> removeAllNodes(String panId) async {
    final int count = await db?.delete(
      'nodes',
      where: 'panId = ?',
      whereArgs: [panId],
    ) ?? 0;
    return count > 0;
  }

  @override
  Future<bool> putNode (CentronicPlusNode node) async {
    try {
      await node.saveToDatabase();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteNode (CentronicPlusNode node) async {
    try {
      await node.deleteFromDatabase();
      return true;
    } catch(e) {
      return false;
    }
  }
}
