part of 'module.dart';

class RemoteVersionsInfo {
  final DateTime? lastUpdate;
  final String? parser;
  final List<RemoteOTAUInfo>? otaFiles;
  final List<RemoteStickInfo>? stickFiles;
  final List<RemoteCC11Info>? cc11Files;
  final List<RemoteInstallationManualInfo>? installationManual;
  final Map<String, dynamic> _source;

  RemoteVersionsInfo({
    required this.lastUpdate,
    required this.parser,
    required this.otaFiles,
    required this.stickFiles,
    // Added Pass-through for parsed CC11 list
    required this.cc11Files,
    required this.installationManual,
    required Map<String, dynamic> source
  }) : _source = source;

  factory RemoteVersionsInfo.fromBytes(List<int> data) {
    Map<String, dynamic> json;
    if(data.isEmpty) {
      json = {};
    } else {
      /// FIXME: All this Mutaturs bullshit is nonsense
      /// FIXME: We should probably use the Evo Modbus Type extension...
      json = jsonDecode(utf8.decode(data));
      /// FIXME: THIS WILL DO NOTHING!
      dev.log(json.toString());
    }

    final lastUpdate = json['last_update'] == null
      ? null
      : DateTime.parse(json['last_update']);

    final ota     = (json['centronic_plus']?['ota'] as List?)?.map((e) => RemoteOTAUInfo.fromJson(e)).toList();
    final stick   = (json['centronic_plus']?['stick'] as List?)?.map((e) => RemoteStickInfo.fromJson(e)).toList();
    // Added Parse optional top-level cc11 list if present; safe no-op when absent
    final cc11    = (json['cc11'] as List?)?.map((e) => RemoteCC11Info.fromJson(e)).toList();
    final manuals = <RemoteInstallationManualInfo>[];

    /// FIXME: Simplify to use factory constructor
    for(final language in (json['documents']?['installation_manual']?['files']?.keys ?? [])) {
      manuals.add(RemoteInstallationManualInfo(
        language: language,
        version: Version.parse(json['documents']?['installation_manual']?['version']?.toString() ?? "0.0.0"),
        path: json['documents']?['installation_manual']?['files']?[language] ?? ""
      ));
    }

    return RemoteVersionsInfo(
      lastUpdate: lastUpdate,
      parser: json['parser'],
      otaFiles: ota,
      stickFiles : stick,
      cc11Files  : cc11,
      installationManual: manuals,
      source: json
    );
  }

  Map<String, dynamic> toJson() => {
    'last_update': lastUpdate?.toIso8601String(),
    'centronic_plus': {
      'ota': otaFiles?.map((e) => e.toJson()).toList(),
      'stick': stickFiles?.map((e) => e.toJson()).toList()
    },
    // Added Echo cc11 list back out for local snapshot mirroring
    'cc11': cc11Files?.map((e) => e.toJson()).toList(),
    'documents': {
      'installation_manual': {
        'version': installationManual?.first.version,
        'files': installationManual?.fold({}, (prev, element) {
          prev[element.language!] = element.path;
          return prev;
        })
      }
    }
  };

  @override
  toString () => _source.toString();
}

class RemoteOTAUInfoUpgradeRequirements {
  final Version? minVersion;
  final Version? maxVersion;
  final Version? excludeVersion;

  RemoteOTAUInfoUpgradeRequirements({
    required this.minVersion,
    required this.maxVersion,
    required this.excludeVersion
  });

  factory RemoteOTAUInfoUpgradeRequirements.fromJson(Map<String, dynamic> json) {
    return RemoteOTAUInfoUpgradeRequirements(
      minVersion: Version.parse(json['min'] ?? "0.0.0"),
      maxVersion: Version.parse(json['max'] ?? "0.0.0"),
      excludeVersion: Version.parse(json['exclude'] ?? "0.0.0")
    );
  }

  Map<String, dynamic> toJson() => {
    'min': minVersion.toString(),
    'max': maxVersion.toString(),
    'exclude': excludeVersion.toString()
  };
}

class RemoteOTAUInfo {
  final String? path;
  final Version version;
  final DateTime? releaseDate;
  final String? articleId;
  final Map<String, dynamic> _source;
  final RemoteOTAUInfoUpgradeRequirements? upgradeRequirements;

  Future<String?> getLocalPath () async {
    try {
      final localDir = await getApplicationDocumentsDirectory();
      if(path == null) return null;
      return "${localDir.path}/$path";
    } catch(e) {
      return null;
    }
  }

  String? get fileName => path?.split('/').last;

  RemoteOTAUInfo({
    required this.path,
    required this.version,
    required this.releaseDate,
    required this.articleId,
    required Map<String, dynamic> source,
    this.upgradeRequirements
  }): _source = source;

  factory RemoteOTAUInfo.fromJson(Map<String, dynamic> json) {
    return RemoteOTAUInfo(
      path: json['path'],
      version: Version.parse(json['version'] ?? "0.0.0"),
      articleId: json['article_id']?.replaceAll(' ', ''),
      source: json,
      upgradeRequirements: json['upgrade_requirements'] == null
        ? null
        : RemoteOTAUInfoUpgradeRequirements.fromJson(json['upgrade_requirements']),
      releaseDate: json['release_date'] == null
        ? null
        : DateTime.parse(json['release_date'])
    );
  }

  bool isNewerThan (RemoteOTAUInfo? other) {
    if(other?.version == null) return true;
    return version > other?.version;
  }

  Future<bool> exists () async {
    if(File(await getLocalPath() ?? "").existsSync()) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'version': version.toString(),
    'release_date': releaseDate?.toIso8601String(),
    'article_id': articleId,
    'upgrade_requirements': upgradeRequirements?.toJson()
  };

  @override
  toString () => _source.toString();
}

class RemoteStickInfo {
  final String? path;
  final Version? version;
  final int pid;
  final DateTime? releaseDate;
  final Map<String, dynamic> _source;

  RemoteStickInfo({
    required this.path,
    required this.version,
    required this.pid,
    required this.releaseDate,
    required Map<String, dynamic> source,
  }): _source = source;

  Future<String?> getLocalPath () async {
    try {
      final localDir = await getApplicationDocumentsDirectory();
      if(path == null) return null;
      return "${localDir.path}/$path";
    } catch(e) {
      return null;
    }
  }

  String? get fileName => path?.split('/').last;

  bool isNewerThan (RemoteStickInfo? other) {
    if(other?.version == null) return true;
    return (version ?? Version(0,0,0)) > (other?.version ?? Version(0,0,0));
  }

  Future<bool> exists () async {
    if(File(await getLocalPath() ?? "").existsSync()) {
      return true;
    }
    return false;
  }

  factory RemoteStickInfo.fromJson(Map<String, dynamic> json) {
    return RemoteStickInfo(
      path: json['path'],
      pid: json['pid'] ?? 0,
      version: Version.parse(json['version'] ?? "0.0.0"),
      source: json,
      releaseDate: json['release_date'] == null
        ? null
        : DateTime.parse(json['release_date'])
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'version': version.toString(),
    'pid': pid,
    'release_date': releaseDate?.toIso8601String()
  };

  @override
  toString () => _source.toString();
}

/// Model for the new object in the json
class RemoteCC11Info {
  final String? path;
  final Version? version;
  final DateTime? releaseDate;
  final Map<String, List<String>>? changelog;
  final Map<String, dynamic> _source;

  RemoteCC11Info({
    required this.path,
    required this.version,
    required this.releaseDate,
    this.changelog,
    required Map<String, dynamic> source,
  }) : _source = source;

  factory RemoteCC11Info.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? parseChangelog(dynamic raw) {
      if (raw is Map) {
        return raw.map<String, List<String>>((key, value) {
          final list = (value as List?)?.map((e) => e.toString()).toList() ?? <String>[];
          return MapEntry(key.toString(), list);
        });
      }
      return null;
    }
    return RemoteCC11Info(
      path: json['path'],
      version: Version.parse(json['version'] ?? '0.0.0'),
      releaseDate: json['release_date'] == null
          ? null
          : DateTime.parse(json['release_date']),
      changelog: parseChangelog(json['changelog']),
      source: json,
    );
  }

  /// Resolve local destination path (same scheme as other assets)
  Future<String?> getLocalPath() async {
    try {
      final localDir = await getApplicationDocumentsDirectory();
      if (path == null) return null;
      return "${localDir.path}/$path";
    } catch (_) {
      return null;
    }
  }

  /// Check if file already exists in cache
  Future<bool> exists() async {
    if (File(await getLocalPath() ?? "").existsSync()) {
      return true;
    }
    return false;
  }

  /// Convenience: compare versions for update need
  bool isNewerThan(RemoteCC11Info? other) {
    if (other?.version == null) return true;
    return (version ?? Version(0, 0, 0)) > (other?.version ?? Version(0, 0, 0));
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'version': version.toString(),
        'release_date': releaseDate?.toIso8601String(),
        'changelog': changelog,
      };

  @override
  toString() => _source.toString();
}
class RemoteInstallationManualInfo {
  final Version? version;
  final String? path;
  final String? language;

  RemoteInstallationManualInfo({
    required this.version,
    required this.path,
    required this.language
  });

  isNewerThan (RemoteInstallationManualInfo? other) {
    if(other == null) return true;
    return (version ?? Version(0,0,0)) > (other.version ?? Version(0,0,0));
  }

  Future<String?> getLocalPath () async {
    try {
      final localDir = await getApplicationDocumentsDirectory();
      if(path == null) return null;
      return "${localDir.path}/$path";
    } catch(e) {
      return null;
    }
  }

  Future<bool> exists () async {
    if(File(await getLocalPath() ?? "").existsSync()) {
      return true;
    }
    return false;
  }

  String? get localFileName => path?.split('/').last;

  Map<String, dynamic> toJson() => {
    'version': version.toString(),
    'file_name': path,
    'language': language,
  };
}
