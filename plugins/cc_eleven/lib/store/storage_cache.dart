part of 'store.dart';

/// Local cache management for binary storage
/// Syncs with device storage based on header lastUpdate timestamp
class CPStorageCache {
  static const String CACHE_DIR = 'cp_storage_cache';
  static const String HEADER_CACHE_FILE = 'storage_header.bin';
  static const String INDEX_CACHE_FILE = 'storage_index.bin';
  static const String DATA_CACHE_PREFIX = 'data_block_';
  static const int BLOCK_SIZE = 128; // Default block size for data reading
  
  final CCEleven ccEleven;
  late Directory _cacheDir;
  late Directory _deviceCacheDir; // UUID-specific cache directory
  late File _headerCacheFile;
  late File _indexCacheFile;
  
  // Cache state
  StorageHeader? _cachedHeader;
  List<TableIndexEntry> _cachedIndex = [];
  final Map<int, List<int>> _cachedDataBlocks = {}; // block_offset -> data
  late String _cacheId;
  
  CPStorageCache(this.ccEleven);
  
  /// Initialize cache directory and files
  Future<void> init(String cacheId) async {
    _cacheId = cacheId;
    try {
      // Get application documents directory
      final appDocsDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory(path.join(appDocsDir.path, CACHE_DIR));
      
      // Create main cache directory if it doesn't exist
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
        dev.log("Created main cache directory: ${_cacheDir.path}", name: 'CPStorageCache');
      }
      
      // Get device UUID from header (this might require a device read initially)
      await _initializeDeviceCacheDir();
      
      dev.log("Cache initialized: ${_deviceCacheDir.path}", name: 'CPStorageCache');
    } catch (e) {
      dev.log("Error initializing cache: $e", name: 'CPStorageCache');
      rethrow;
    }
  }
  
  /// Initialize device-specific cache directory based on UUID
  Future<void> _initializeDeviceCacheDir() async {
    try {
      // Try to read device header to get UUID
      // final deviceHeaderData = await ccEleven.readUserdata(offset: 0, len: StorageHeader.HEADER_SIZE);
      
      // String deviceUuid;
      // if (deviceHeaderData == null || deviceHeaderData.length < StorageHeader.HEADER_SIZE) {
      //   // No valid header on device, create new UUID and use it
      //   dev.log("No valid header found, will use new UUID when header is created", name: 'CPStorageCache');
      //   deviceUuid = 'temp'; // Temporary until header is created
      // } else {
      //   final header = StorageHeader.deserialize(deviceHeaderData);
      //   deviceUuid = header.uuidShort; // Use short UUID for directory name
      //   dev.log("Found device UUID: ${header.uuidString} (short: $deviceUuid)", name: 'CPStorageCache');
      // }
      
      _deviceCacheDir = Directory(path.join(_cacheDir.path, _cacheId));
      
      // Create device-specific cache directory
      if (!await _deviceCacheDir.exists()) {
        await _deviceCacheDir.create(recursive: true);
        dev.log("Created device cache directory: ${_deviceCacheDir.path}", name: 'CPStorageCache');
      }
      
      // Set up cache files in device-specific directory
      _headerCacheFile = File(path.join(_deviceCacheDir.path, HEADER_CACHE_FILE));
      _indexCacheFile = File(path.join(_deviceCacheDir.path, INDEX_CACHE_FILE));
      
    } catch (e) {
      dev.log("Error initializing device cache directory: $e", name: 'CPStorageCache');
      // Fallback to main cache directory
      _deviceCacheDir = _cacheDir;
      _headerCacheFile = File(path.join(_cacheDir.path, HEADER_CACHE_FILE));
      _indexCacheFile = File(path.join(_cacheDir.path, INDEX_CACHE_FILE));
    }
  }
  
  /// Check if local cache is valid by comparing header lastUpdate
  Future<bool> isCacheValid() async {
    try {
      // Get current header from device
      final deviceHeaderData = await ccEleven.readUserdata(offset: 0, len: StorageHeader.HEADER_SIZE);
      if (deviceHeaderData == null || deviceHeaderData.length < StorageHeader.HEADER_SIZE) {
        dev.log("No valid header on device", name: 'CPStorageCache');
        return false;
      }
      
      final deviceHeader = StorageHeader.deserialize(deviceHeaderData);
      
      // Load cached header if exists
      if (!await _headerCacheFile.exists()) {
        dev.log("No cached header found", name: 'CPStorageCache');
        return false;
      }
      
      final cachedHeaderData = await _headerCacheFile.readAsBytes();
      final cachedHeader = StorageHeader.deserialize(cachedHeaderData);
      
      // Compare lastUpdate timestamps
      final isValid = cachedHeader.lastUpdate == deviceHeader.lastUpdate;
      
      dev.log("Cache validation: device=${deviceHeader.lastUpdate}, cached=${cachedHeader.lastUpdate}, valid=$isValid", 
              name: 'CPStorageCache');
      
      return isValid;
    } catch (e) {
      dev.log("Error validating cache: $e", name: 'CPStorageCache');
      return false;
    }
  }

  /// Synchronize cache with device using granular entry-level timestamps
  /// Returns list of updated entry IDs
  Future<List<String>> synchronizeCache() async {
    final updatedEntries = <String>[];
    
    try {
      dev.log("Starting granular cache synchronization", name: 'CPStorageCache');
      
      // Force load device header and index (bypass cache completely)
      final deviceHeaderData = await ccEleven.readUserdata(offset: 0, len: StorageHeader.HEADER_SIZE);
      if (deviceHeaderData == null) {
        dev.log("Cannot read device header for sync", name: 'CPStorageCache');
        return updatedEntries;
      }
      
      final deviceHeader = StorageHeader.deserialize(deviceHeaderData);
      dev.log("Device header: ${deviceHeader.lastUpdate}, index length: ${deviceHeader.lengthOfIndex}", name: 'CPStorageCache');
      
      // Force load device index in batches (bypass cache completely, BLE-optimized)
      final deviceIndex = await _loadIndexFromDevice(deviceHeader.lengthOfIndex, context: ' for sync');
      
      // Load cached index DIRECTLY from cache (not through loadIndex method)
      List<TableIndexEntry> cachedIndex = [];
      if (await _indexCacheFile.exists()) {
        final cachedIndexData = await _indexCacheFile.readAsBytes();
        cachedIndex = _deserializeIndex(cachedIndexData);
      }
      dev.log("Cached index loaded: ${cachedIndex.length} entries", name: 'CPStorageCache');
      
      // Create maps for efficient lookup - only include active entries (not TableEntryType.none)
      final Map<String, TableIndexEntry> deviceEntryMap = {};
      final Map<String, TableIndexEntry> cachedEntryMap = {};
      
      // Only include entries that are NOT marked as deleted (TableEntryType.none)
      for (final entry in deviceIndex) {
        if (entry.type != TableEntryType.none) {
          deviceEntryMap[entry.idAsString] = entry;
        }
      }
      
      for (final entry in cachedIndex) {
        if (entry.type != TableEntryType.none) {
          cachedEntryMap[entry.idAsString] = entry;
        }
      }
      
      // Check for new or updated entries on device
      for (final deviceEntry in deviceIndex) {
        final entryId = deviceEntry.idAsString;
        
        // Skip entries marked as deleted
        if (deviceEntry.type == TableEntryType.none) {
          continue;
        }
        
        final cachedEntry = cachedEntryMap[entryId];
        
        if (cachedEntry == null) {
          // New entry - cache data block
          dev.log("New entry found: $entryId (type: ${deviceEntry.type})", name: 'CPStorageCache');
          await _syncDataBlock(deviceEntry);
          updatedEntries.add(entryId);
        } else if (deviceEntry.isNewerThan(cachedEntry)) {
          // Updated entry - refresh data block (must be newer AND not marked as deleted)
          dev.log("Updated entry found: $entryId (type: ${deviceEntry.type}, device: ${deviceEntry.lastUpdateDateTime}, cached: ${cachedEntry.lastUpdateDateTime})", 
                  name: 'CPStorageCache');
          await _syncDataBlock(deviceEntry);
          updatedEntries.add(entryId);
        }
      }
      
      // Check for entries that were deleted on device (exist in cache but not in active device entries)
      // This includes entries that were marked as TableEntryType.none on device
      for (final cachedEntry in cachedIndex) {
        final entryId = cachedEntry.idAsString;
        
        // Skip if cached entry was already marked as deleted
        if (cachedEntry.type == TableEntryType.none) {
          continue;
        }
        
        // Check if entry no longer exists as active entry on device
        if (!deviceEntryMap.containsKey(entryId)) {
          // Entry was either completely removed or marked as TableEntryType.none
          dev.log("Deleted entry found: $entryId", name: 'CPStorageCache');
          await _removeDataBlockFromCache(cachedEntry.offset);
          updatedEntries.add(entryId);
        }
      }
      
      // Update cached index and header with device data
      await _saveIndexToCache(deviceIndex);
      await _saveHeaderToCache(deviceHeader);
      
      // Update in-memory cache state
      _cachedIndex = deviceIndex;
      _cachedHeader = deviceHeader;
      
      dev.log("Granular sync completed: ${updatedEntries.length} entries updated", name: 'CPStorageCache');
      
      return updatedEntries;
    } catch (e) {
      dev.log("Error in granular cache sync: $e", name: 'CPStorageCache');
      return updatedEntries;
    }
  }

  /// Sync a single data block from device to cache
  Future<void> _syncDataBlock(TableIndexEntry entry) async {
    try {
      // Determine appropriate read size based on entry type
      int readSize = BLOCK_SIZE; // Default to block size
      
      // For specific types, we might want different read sizes
      switch (entry.type) {
        case TableEntryType.cpNode:
          readSize = CpNodeBinaryData.ENTRY_SIZE;
          break;
        case TableEntryType.group:
          readSize = CCGroup.ENTRY_SIZE;
          break;
        case TableEntryType.string:
          readSize = BLOCK_SIZE; // Strings use variable length, read full block
          break;
        default:
          readSize = BLOCK_SIZE;
      }
      
      final data = await ccEleven.readUserdata(offset: entry.offset, len: readSize);
      if (data != null) {
        _cachedDataBlocks[entry.offset] = List.from(data);
        await _saveDataBlockToCache(entry.offset, data);
        dev.log("Synced data block at offset ${entry.offset} (${data.length} bytes)", name: 'CPStorageCache');
      }
    } catch (e) {
      dev.log("Error syncing data block for entry ${entry.idAsString}: $e", name: 'CPStorageCache');
    }
  }

  /// Remove data block from cache
  Future<void> _removeDataBlockFromCache(int offset) async {
    try {
      _cachedDataBlocks.remove(offset);
      final cacheFile = File('${_deviceCacheDir.path}/${DATA_CACHE_PREFIX}${offset}.bin');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
        dev.log("Removed cached data block at offset $offset", name: 'CPStorageCache');
      }
    } catch (e) {
      dev.log("Error removing cached data block at offset $offset: $e", name: 'CPStorageCache');
    }
  }
  
  /// Load header from cache first, fallback to device
  Future<StorageHeader> loadHeader({bool cacheFirst = true}) async {
    try {
      // Cache-first approach for cold start
      if (cacheFirst && await _hasCachedHeader()) {
        await _loadCachedHeader();
        if (_cachedHeader != null) {
          dev.log("Using cached header (cache-first)", name: 'CPStorageCache');
          return _cachedHeader!;
        }
      }
      
      // Validate cache against device if needed
      if (!cacheFirst && await isCacheValid() && _cachedHeader != null) {
        dev.log("Using cached header (validated)", name: 'CPStorageCache');
        return _cachedHeader!;
      }
      
      // Load from device
      final deviceHeaderData = await ccEleven.readUserdata(offset: 0, len: StorageHeader.HEADER_SIZE);
      if (deviceHeaderData == null || deviceHeaderData.length < StorageHeader.HEADER_SIZE) {
        // Create empty header
        _cachedHeader = StorageHeader.empty(_cacheId);
        await _saveHeaderToCache(_cachedHeader!);
        dev.log("Created new empty header", name: 'CPStorageCache');
        return _cachedHeader!;
      }
      
      _cachedHeader = StorageHeader.deserialize(deviceHeaderData);
      await _saveHeaderToCache(_cachedHeader!);
      
      dev.log("Loaded header from device and cached", name: 'CPStorageCache');
      return _cachedHeader!;
    } catch (e) {
      dev.log("Error loading header: $e", name: 'CPStorageCache');
      rethrow;
    }
  }
  
  /// Load index from cache first, fallback to device
  Future<List<TableIndexEntry>> loadIndex({bool cacheFirst = true}) async {
    try {
      // Cache-first approach for cold start
      if (cacheFirst && await _hasCachedIndex()) {
        await _loadCachedIndex();
        if (_cachedIndex.isNotEmpty) {
          dev.log("Using cached index (cache-first, ${_cachedIndex.length} entries)", name: 'CPStorageCache');
          return _cachedIndex;
        }
      }
      
      // Validate cache against device if needed
      if (!cacheFirst && await isCacheValid() && _cachedIndex.isNotEmpty) {
        dev.log("Using cached index (validated, ${_cachedIndex.length} entries)", name: 'CPStorageCache');
        return _cachedIndex;
      }
      
      // Load from device
      final header = await loadHeader(cacheFirst: cacheFirst);
      if (header.lengthOfIndex == 0) {
        _cachedIndex = [];
        await _saveIndexToCache(_cachedIndex);
        dev.log("No index entries on device", name: 'CPStorageCache');
        return _cachedIndex;
      }
      
      // Read index entries from device using shared helper
      final indexEntries = await _loadIndexFromDevice(header.lengthOfIndex);
      
      _cachedIndex = indexEntries;
      await _saveIndexToCache(_cachedIndex);
      
      dev.log("Loaded index from device and cached (${_cachedIndex.length} entries, batch reads)", name: 'CPStorageCache');
      return _cachedIndex;
    } catch (e) {
      dev.log("Error loading index: $e", name: 'CPStorageCache');
      rethrow;
    }
  }
  
  /// Load data block from cache or device
  Future<List<int>?> loadDataBlock(int offset, int length, {bool cacheFirst = false}) async {
    try {
      // Check in-memory cache first
      if (_cachedDataBlocks.containsKey(offset)) {
        dev.log("Using in-memory cached data block at offset $offset", name: 'CPStorageCache');
        return _cachedDataBlocks[offset];
      }
      
      // If cacheFirst, try to load from disk cache
      if (cacheFirst) {
        final cachedData = await _loadDataBlockFromCache(offset, length);
        if (cachedData != null) {
          _cachedDataBlocks[offset] = cachedData;
          dev.log("Loaded data block from disk cache (offset: $offset, cache-first)", name: 'CPStorageCache');
          return cachedData;
        }
      }
      
      // Load from device
      final data = await ccEleven.readUserdata(offset: offset, len: length);
      if (data != null) {
        _cachedDataBlocks[offset] = data;
        await _saveDataBlockToCache(offset, data);
        dev.log("Loaded data block from device and cached (offset: $offset, length: $length)", name: 'CPStorageCache');
      }
      
      return data;
    } catch (e) {
      dev.log("Error loading data block: $e", name: 'CPStorageCache');
      return null;
    }
  }
  
  /// Save header to device and update cache
  Future<void> saveHeader(StorageHeader header) async {
    try {
      // Update device cache directory
      _deviceCacheDir = Directory(path.join(_cacheDir.path, _cacheId));
      if (!await _deviceCacheDir.exists()) {
        await _deviceCacheDir.create(recursive: true);
      }
      
      // Update cache file paths
      _headerCacheFile = File(path.join(_deviceCacheDir.path, HEADER_CACHE_FILE));
      _indexCacheFile = File(path.join(_deviceCacheDir.path, INDEX_CACHE_FILE));
      
      // Clear in-memory cache since we're switching devices
      _cachedHeader = null;
      _cachedIndex.clear();
      _cachedDataBlocks.clear();
      
      // Update timestamp
      header.updateTimestamp();
      
      // Save to device
      await ccEleven.writeUserdata(offset: 0, data: header.serialize());
      
      // Update cache
      _cachedHeader = header;
      await _saveHeaderToCache(header);
      
      dev.log("Header saved to device and cache (UUID: ${header.uuidString})", name: 'CPStorageCache');
    } catch (e) {
      dev.log("Error saving header: $e", name: 'CPStorageCache');
      rethrow;
    }
  }
  
  /// Save index to device and update cache (individual entry writes)
  Future<void> saveIndex(List<TableIndexEntry> index) async {
    try {
      dev.log("Saving ${index.length} index entries individually ", name: 'CPStorageCache');
      
      for (int i = 0; i < index.length; i++) {
        final entry = index[i];
        final entryOffset = StorageHeader.HEADER_SIZE + (i * TableIndexEntry.INDEX_ENTRY_SIZE);
        final entryData = entry.serialize();
        
        if(entry.isDirty) {
          await ccEleven.writeUserdata(offset: entryOffset, data: entryData);
          entry.markClean();
        }

        
        dev.log("Wrote index entry $i at offset $entryOffset (${entryData.length} bytes)", name: 'CPStorageCache');
      }
      
      // Update cache
      _cachedIndex = List.from(index);
      await _saveIndexToCache(_cachedIndex);
      
      dev.log("Index saved to device and cache (${index.length} entries, individual writes)", name: 'CPStorageCache');
    } catch (e) {
      dev.log("Error saving index: $e", name: 'CPStorageCache');
      rethrow;
    }
  }

  /// Save only dirty index entries incrementally 
  Future<void> saveIndexIncremental(List<TableIndexEntry> index) async {
    try {
      // Find dirty entries
      final dirtyEntries = index.where((entry) => entry.isDirty).toList();
      
      if (dirtyEntries.isEmpty) {
        dev.log("No dirty index entries to save incrementally", name: 'CPStorageCache');
        return;
      }
      
      dev.log("Saving ${dirtyEntries.length} dirty index entries incrementally", name: 'CPStorageCache');
      
      // Save each dirty entry individually
      for (int i = 0; i < index.length; i++) {
        final entry = index[i];
        if (entry.isDirty) {
          // Calculate offset for this specific index entry
          final entryOffset = StorageHeader.HEADER_SIZE + (i * TableIndexEntry.INDEX_ENTRY_SIZE);
          final entryData = entry.serialize();
          
          // Write individual entry to device (21 bytes vs potentially KB of full index)
          await ccEleven.writeUserdata(offset: entryOffset, data: entryData);
          
          dev.log("Updated index entry $i at offset $entryOffset (${entryData.length} bytes)", name: 'CPStorageCache');
        }
      }
      
      // Update cache
      _cachedIndex = List.from(index);
      await _saveIndexToCache(_cachedIndex);
      
      dev.log("Incremental index save completed (${dirtyEntries.length} entries updated)", name: 'CPStorageCache');
    } catch (e) {
      dev.log("Error saving index incrementally: $e", name: 'CPStorageCache');
      rethrow;
    }
  }
  
  /// Save data block to device and update cache
  Future<void> saveDataBlock(int offset, List<int> data) async {
    try {
      // Save to device (data is already optimized by the serialize() method)
      await ccEleven.writeUserdata(offset: offset, data: data);
      
      // Update cache (store the data as-is for consistency)
      _cachedDataBlocks[offset] = List.from(data);
      await _saveDataBlockToCache(offset, data);
      
      dev.log("Data block saved to device and cache (offset: $offset, size: ${data.length} bytes)", name: 'CPStorageCache');
    } catch (e) {
      dev.log("Error saving data block: $e", name: 'CPStorageCache');
      rethrow;
    }
  }
  
  /// Clear all cache
  Future<void> clearCache() async {
    try {
      if (await _cacheDir.exists()) {
        await _cacheDir.delete(recursive: true);
        await _cacheDir.create(recursive: true);
      }
      
      _cachedHeader = null;
      _cachedIndex.clear();
      _cachedDataBlocks.clear();
      
      dev.log("Cache cleared", name: 'CPStorageCache');
    } catch (e) {
      dev.log("Error clearing cache: $e", name: 'CPStorageCache');
    }
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheDir': _cacheDir.path,
      'deviceCacheDir': _deviceCacheDir.path,
      'currentUuid': _cacheId,
      'hasHeader': _cachedHeader != null,
      'indexEntries': _cachedIndex.length,
      'cachedDataBlocks': _cachedDataBlocks.length,
      'headerFile': _headerCacheFile.path,
      'indexFile': _indexCacheFile.path,
    };
  }
  
  // Private helper methods
  
  Future<void> _saveHeaderToCache(StorageHeader header) async {
    try {
      await _headerCacheFile.writeAsBytes(header.serialize());
    } catch (e) {
      dev.log("Error saving header to cache: $e", name: 'CPStorageCache');
    }
  }
  
  Future<void> _saveIndexToCache(List<TableIndexEntry> index) async {
    try {
      final indexData = _serializeIndex(index);
      await _indexCacheFile.writeAsBytes(indexData);
    } catch (e) {
      dev.log("Error saving index to cache: $e", name: 'CPStorageCache');
    }
  }
  
  Future<void> _saveDataBlockToCache(int offset, List<int> data) async {
    try {
      final blockFile = File(path.join(_deviceCacheDir.path, '$DATA_CACHE_PREFIX$offset.bin'));
      await blockFile.writeAsBytes(data);
    } catch (e) {
      dev.log("Error saving data block to cache: $e", name: 'CPStorageCache');
    }
  }
  
  Future<List<int>?> _loadDataBlockFromCache(int offset, int length) async {
    try {
      final blockFile = File(path.join(_deviceCacheDir.path, '$DATA_CACHE_PREFIX$offset.bin'));
      if (await blockFile.exists()) {
        final data = await blockFile.readAsBytes();
        // Validate length matches expected
        if (data.length == length) {
          return data;
        } else {
          dev.log("Cached data block size mismatch at offset $offset (expected: $length, got: ${data.length})", name: 'CPStorageCache');
          // Delete invalid cached file
          await blockFile.delete();
        }
      }
      return null;
    } catch (e) {
      dev.log("Error loading data block from cache: $e", name: 'CPStorageCache');
      return null;
    }
  }
  
  List<int> _serializeIndex(List<TableIndexEntry> index) {
    final data = <int>[];
    for (final entry in index) {
      data.addAll(entry.serialize());
    }
    return data;
  }
  
  List<TableIndexEntry> _deserializeIndex(List<int> data) {
    final entries = <TableIndexEntry>[];
    for (int i = 0; i < data.length; i += TableIndexEntry.INDEX_ENTRY_SIZE) {
      final entryData = data.sublist(i, i + TableIndexEntry.INDEX_ENTRY_SIZE);
      entries.add(TableIndexEntry.deserialize(entryData));
    }
    return entries;
  }

  /// Load index entries from device in batches for optimal BLE performance
  /// Returns list of TableIndexEntry objects read from device
  Future<List<TableIndexEntry>> _loadIndexFromDevice(int numberOfEntries, {String context = ''}) async {
    if (numberOfEntries == 0) {
      dev.log("No index entries to load from device$context", name: 'CPStorageCache');
      return [];
    }
    
    const int maxEntriesPerRead = 5;
    dev.log("Reading $numberOfEntries device index entries in batches of $maxEntriesPerRead$context", name: 'CPStorageCache');
    final indexEntries = <TableIndexEntry>[];
    
    for (int i = 0; i < numberOfEntries; i += maxEntriesPerRead) {
      final remainingEntries = numberOfEntries - i;
      final entriesToRead = remainingEntries > maxEntriesPerRead ? maxEntriesPerRead : remainingEntries;
      final batchSize = entriesToRead * TableIndexEntry.INDEX_ENTRY_SIZE;
      
      final entryOffset = StorageHeader.HEADER_SIZE + (i * TableIndexEntry.INDEX_ENTRY_SIZE);
      final batchData = await ccEleven.readUserdata(
        offset: entryOffset, 
        len: batchSize
      );
      
      if (batchData == null || batchData.length < batchSize) {
        dev.log("Failed to read device index entries batch starting at $i$context (expected $batchSize bytes)", name: 'CPStorageCache');
        // Try to read remaining entries individually as fallback
        for (int j = i; j < numberOfEntries; j++) {
          final singleEntryOffset = StorageHeader.HEADER_SIZE + (j * TableIndexEntry.INDEX_ENTRY_SIZE);
          final singleEntryData = await ccEleven.readUserdata(
            offset: singleEntryOffset, 
            len: TableIndexEntry.INDEX_ENTRY_SIZE
          );
          
          if (singleEntryData == null || singleEntryData.length < TableIndexEntry.INDEX_ENTRY_SIZE) {
            dev.log("Failed to read device index entry $j$context", name: 'CPStorageCache');
            break;
          }
          
          final entry = TableIndexEntry.deserialize(singleEntryData);
          indexEntries.add(entry);
          dev.log("Read index entry $j: ${entry.idAsString} (type: ${entry.type})$context [fallback]", name: 'CPStorageCache');
        }
        break;
      }
      
      // Deserialize batch data into individual entries
      for (int j = 0; j < entriesToRead; j++) {
        final entryStart = j * TableIndexEntry.INDEX_ENTRY_SIZE;
        final entryEnd = entryStart + TableIndexEntry.INDEX_ENTRY_SIZE;
        final entryData = batchData.sublist(entryStart, entryEnd);
        
        final entry = TableIndexEntry.deserialize(entryData);
        indexEntries.add(entry);
        dev.log("Read index entry ${i + j}: ${entry.idAsString} (type: ${entry.type})$context [batch]", name: 'CPStorageCache');
      }
    }
    
    dev.log("Device index loaded: ${indexEntries.length} entries (batch reads)$context", name: 'CPStorageCache');
    return indexEntries;
  }

  /// Check if cached header exists on disk
  Future<bool> _hasCachedHeader() async {
    return await _headerCacheFile.exists();
  }

  /// Check if cached index exists on disk
  Future<bool> _hasCachedIndex() async {
    return await _indexCacheFile.exists();
  }

  /// Load header from disk cache into memory
  Future<void> _loadCachedHeader() async {
    try {
      if (await _headerCacheFile.exists()) {
        final cachedHeaderData = await _headerCacheFile.readAsBytes();
        _cachedHeader = StorageHeader.deserialize(cachedHeaderData);
      }
    } catch (e) {
      dev.log("Error loading cached header: $e", name: 'CPStorageCache');
      _cachedHeader = null;
    }
  }

  /// Load index from disk cache into memory
  Future<void> _loadCachedIndex() async {
    try {
      if (await _indexCacheFile.exists()) {
        final cachedIndexData = await _indexCacheFile.readAsBytes();
        _cachedIndex = _deserializeIndex(cachedIndexData);
      }
    } catch (e) {
      dev.log("Error loading cached index: $e", name: 'CPStorageCache');
      _cachedIndex = [];
    }
  }
}
