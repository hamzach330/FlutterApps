part of 'store.dart';

/// Binary-based storage with header, index and typed data
/// Uses fixed 32KB storage with 128-byte block allocation (no fragmentation)
/// Includes local file system cache with lastUpdate-based sync
class CPBinaryStore {
  static CPBinaryStore? store;
  
  // Fixed 32KB storage layout with 128-byte blocks
  static const int STORAGE_SIZE = 32 * 1024; // 32KB total
  static const int HEADER_SIZE = 36; // Fixed header size (updated for UUID)
  static const int BLOCK_SIZE = 128; // Fixed block size for all data entries
  static const int TOTAL_BLOCKS = STORAGE_SIZE ~/ BLOCK_SIZE; // 256 blocks total
  
  late CPStorageCache _cache; // Local file system cache
  late CPStorageLock _lock; // Concurrency control
  late String _deviceId;
  StorageHeader? _header;
  final List<TableIndexEntry> _index = [];

  get _nextFreeBlock {
    for(int i = 0; i < _index.length; i++) {
      if(_index[i].type == TableEntryType.none) {
        return TOTAL_BLOCKS - (i + 1);
      }
    }
    return TOTAL_BLOCKS - (_index.length + 1);
  }

  get header => _header;

  Future<void> initializeTables(CCEleven ccEleven, String cacheId) async {
    _deviceId = cacheId;
    _cache = CPStorageCache(ccEleven);
    _lock = CPStorageLock(ccEleven);
    store = this;
    dev.log("Initializing binary store with cache-first approach and lock management", name: 'CPBinaryStore.initializeTables');
    
    // Initialize cache system
    await _cache.init(_deviceId);
    
    // Load header and index from cache FIRST (cold start optimization)
    await _loadHeader(cacheFirst: true);
    await _loadIndex(cacheFirst: true);
    
    dev.log("Storage initialized (cache-first): ${getStorageStats()}", name: 'CPBinaryStore');
    
    // Start background cache validation (non-blocking)
    // unawaited(validateCache());
    // await validateCache();
  }

  /// Load storage header from cache or device
  Future<void> _loadHeader({bool cacheFirst = false}) async {
    try {
      _header = await _cache.loadHeader(cacheFirst: cacheFirst);
      if (cacheFirst) {
        dev.log("Loaded header (cache-first): $_header", name: 'CPBinaryStore');
      } else {
        dev.log("Loaded header (validated): $_header", name: 'CPBinaryStore');
      }
    } catch (e) {
      dev.log("Error loading header: $e", name: 'CPBinaryStore');
      _header = StorageHeader.empty(_deviceId);
    }
  }

  /// Load index from cache or device
  Future<void> _loadIndex({bool cacheFirst = false}) async {
    if (_header == null) return;
    
    try {
      _index.clear();
      for(final entry in await _cache.loadIndex(cacheFirst: cacheFirst)) {
        _index.add(entry);
      }
      if (cacheFirst) {
        dev.log("Loaded ${_index.length} index entries (cache-first)", name: 'CPBinaryStore');
      } else {
        dev.log("Loaded ${_index.length} index entries (validated)", name: 'CPBinaryStore');
      }
    } catch (e) {
      dev.log("Error loading index: $e", name: 'CPBinaryStore');
      _index.clear();
    }
  }

  /// Save only dirty index entries (BLE-optimized incremental updates)
  Future<void> _saveIndex() async {
    if (_header == null) return;
    
    try {
      // Find dirty entries that need to be saved
      final dirtyEntries = _index.where((entry) => entry.isDirty).toList();
      
      if (dirtyEntries.isEmpty) {
        dev.log("No dirty index entries for incremental save", name: 'CPBinaryStore');
        return;
      }
      
      // Update header with current index length (only if index size changed)
      final originalIndexLength = _header!.lengthOfIndex;
      _header!.lengthOfIndex = _index.length;
      
      // Save header if index size changed
      if (_header!.lengthOfIndex != originalIndexLength) {
        await _saveHeader();
        dev.log("Updated header: index length changed from $originalIndexLength to ${_header!.lengthOfIndex}", name: 'CPBinaryStore');
      }
      
      // Use incremental save for index entries
      await _cache.saveIndexIncremental(_index);
      
      // Mark all entries as clean after successful save
      for (final entry in _index) {
        entry.markClean();
      }
      
      dev.log("Incremental save completed: ${dirtyEntries.length} dirty entries updated", name: 'CPBinaryStore');
    } catch (e) {
      dev.log("Error in incremental index save: $e", name: 'CPBinaryStore');
      rethrow;
    }
  }

  Future<void> _indexInsert(TableIndexEntry entry) async {
    final emptyEntry = _index.indexWhere((e) => e.type == TableEntryType.none);
    if (emptyEntry != -1) {
      _index[emptyEntry] = entry;
    } else {
      _index.add(entry);
    }
  }

  // =================================
  // LOCK-AWARE OPERATIONS
  // =================================

  /// Execute write operation with lock management
  Future<T> _executeWithLock<T>(Future<T> Function() operation) async {
    return await _lock.executeWrite(operation);
  }

  /// Execute read operation with lock awareness
  Future<T> _executeRead<T>(Future<T> Function() operation) async {
    return await _lock.executeRead(operation);
  }

  /// Get lock statistics for debugging
  Map<String, dynamic> getLockStats() {
    return _lock.getLockStats();
  }

  /// Save header to device and cache
  Future<void> _saveHeader() async {
    if (_header == null) return;
    
    try {
      await _cache.saveHeader(_header!);
      dev.log("Saved header via cache", name: 'CPBinaryStore');
    } catch (e) {
      dev.log("Error saving header: $e", name: 'CPBinaryStore');
      rethrow;
    }
  }

  /// Validate cache in background and update if needed (non-blocking)
  Future<void> validateCache() async {
    try {
      final isValid = await _cache.isCacheValid();
      if (!isValid) {
        dev.log("Cache invalid, performing granular synchronization", name: 'CPBinaryStore');
        
        // Perform granular synchronization instead of full reload
        final updatedEntries = await _cache.synchronizeCache();
        
        if (updatedEntries.isNotEmpty) {
          // Reload header and index after synchronization
          await _loadHeader(cacheFirst: true);
          await _loadIndex(cacheFirst: true);
          
          dev.log("Granular sync completed: ${updatedEntries.length} entries updated", name: 'CPBinaryStore');
        } else {
          dev.log("No updates needed during synchronization", name: 'CPBinaryStore');
        }
      } else {
        dev.log("Cache is valid, no refresh needed", name: 'CPBinaryStore');
      }
      
      // _cacheFirstMode = false;
      // dev.log("Switched to device-first mode after background validation", name: 'CPBinaryStore');
    } catch (e) {
      dev.log("Error validating cache in background: $e", name: 'CPBinaryStore');
    }
  }

  /// Find next free block for data (128-byte blocks, no fragmentation)
  /// Returns the byte offset of the allocated block
  int _allocateBlock() {
    if (_nextFreeBlock >= TOTAL_BLOCKS) {
      throw StateError('Storage full: No more blocks available');

    }
    
    // Check if we have enough space (collision detection with index)
    final indexEnd = HEADER_SIZE + (_index.length * TableIndexEntry.INDEX_ENTRY_SIZE);
    final blockOffset = _nextFreeBlock * BLOCK_SIZE;
    
    if (blockOffset <= indexEnd + BLOCK_SIZE) {
      throw StateError('Storage full: Block area collides with index area');
    }

    return blockOffset; // Return offset of allocated block
  }
  
  /// Check if storage has space for new entry (always 1 block = 128 bytes)
  bool _hasSpaceForEntry() {
    if (_nextFreeBlock >= TOTAL_BLOCKS) {
      return false;
    }
    return true;
  }
  
  /// Get storage utilization statistics
  Map<String, dynamic> getStorageStats() {
    final indexEnd = HEADER_SIZE + (_index.length * TableIndexEntry.INDEX_ENTRY_SIZE);
    final usedBlocks = _index.where((entry) => entry.type != TableEntryType.none).length;
    final usedSpace = (usedBlocks * BLOCK_SIZE);
    final freeBlocks = TOTAL_BLOCKS - usedBlocks;
    final freeSpace = STORAGE_SIZE - usedSpace;
    
    return {
      'totalSize': STORAGE_SIZE,
      'totalBlocks': TOTAL_BLOCKS,
      'blockSize': BLOCK_SIZE,
      'usedBlocks': usedBlocks,
      'freeBlocks': freeBlocks,
      'usedSpace': usedSpace,
      'freeSpace': freeSpace,
      'utilization': '${(usedSpace / STORAGE_SIZE * 100).toStringAsFixed(1)}%',
      'indexEnd': indexEnd,
      'nextFreeBlock': _nextFreeBlock,
      'maxEntries': freeSpace ~/ (BLOCK_SIZE + TableIndexEntry.INDEX_ENTRY_SIZE),
    };
  }
  
  /// Read data entry from cache or device
  Future<List<int>?> _readDataEntry(int offset, int size, {bool cacheFirst = true}) async {
    try {
      // Use cacheFirst parameter if provided, otherwise use current mode
      final useCacheFirst = cacheFirst;
      return await _cache.loadDataBlock(offset, size, cacheFirst: useCacheFirst);
    } catch (e) {
      dev.log("Error reading data entry at offset $offset: $e", name: 'CPBinaryStore');
      return null;
    }
  }

  /// Write data entry to device and cache
  Future<void> _writeDataEntry(int offset, List<int> data) async {
    try {
      await _cache.saveDataBlock(offset, data);
      dev.log("Wrote data entry via cache at offset $offset (${data.length} bytes)", name: 'CPBinaryStore');
    } catch (e) {
      dev.log("Error writing data entry at offset $offset: $e", name: 'CPBinaryStore');
      rethrow;
    }
  }

  Future<CentronicPlusNode?> getNode(String mac, CentronicPlus cp) async {
    try {
      final macBytes = CpNodeBinaryData.macStringToBytes(mac);
      
      // Find index entry
      TableIndexEntry? indexEntry;
      for (final entry in _index) {
        if (entry.type == TableEntryType.cpNode && entry.id.equals(macBytes)) {
          indexEntry = entry;
          break;
        }
      }
      
      if (indexEntry == null) {
        return null;
      }
      
      // Read data
      final data = await _readDataEntry(indexEntry.offset, CpNodeBinaryData.ENTRY_SIZE);
      if (data == null) {
        return null;
      }
      
      // Deserialize and convert to node
      final nodeData = CpNodeBinaryData.deserialize(data);
      return nodeData.toNode(cp);
    } catch (e) {
      dev.log("Error getting node $mac: $e", name: 'CPBinaryStore');
      return null;
    }
  }

  Future<List<CentronicPlusNode>> getAllNodes(CentronicPlus cp) async {
    try {
      final List<CentronicPlusNode> result = [];
      
      for (final entry in _index) {
        if (entry.type == TableEntryType.cpNode) {
          final data = await _readDataEntry(entry.offset, CpNodeBinaryData.ENTRY_SIZE);
          if (data != null) {
            final nodeData = CpNodeBinaryData.deserialize(data);
            final node = nodeData.toNode(cp);
            
            if(cp.pan == "") {
              cp.pan = node.panId ?? "";
            }

            if (node.panId == cp.pan) {
              result.add(node);
            } else {
              // await deleteNode(node);
            }
          }
        }
      }
      
      dev.log("Found ${result.length} nodes in binary database for PAN ${cp.pan}", name: 'CPBinaryStore');
      return result;
    } catch (e) {
      dev.log("Error getting all nodes: $e", name: 'CPBinaryStore');
      return [];
    }
  }

  Future<bool> removeAllNodes(String panId) async {
    try {
      final List<TableIndexEntry> toRemove = [];
      
      for (final entry in _index) {
        if (entry.type == TableEntryType.cpNode) {
          final data = await _readDataEntry(entry.offset, CpNodeBinaryData.ENTRY_SIZE);
          if (data != null) {
            final nodeData = CpNodeBinaryData.deserialize(data);
            if (CpNodeBinaryData.panIdBytesToString(nodeData.panId) == panId) {
              toRemove.add(entry);
            }
          }
        }
      }
      
      for (final entry in toRemove) {
        _index.remove(entry);
      }
      
      if (toRemove.isNotEmpty) {
        await _saveIndex();
        await _saveHeader();
        return true;
      }
      
      return false;
    } catch (e) {
      dev.log("Error removing all nodes for PAN $panId: $e", name: 'CPBinaryStore');
      return false;
    }
  }

  Future<bool> putNode(CentronicPlusNode node) async {
    try {
      await saveNodeData(node);
      return true;
    } catch (e) {
      dev.log("Error putting node ${node.mac}: $e", name: 'CPBinaryStore');
      return false;
    }
  }

  Future<bool> deleteNode(CentronicPlusNode node) async {
    try {
      return await removeNodeData(node.mac);
    } catch (e) {
      dev.log("Error deleting node ${node.mac}: $e", name: 'CPBinaryStore');
      return false;
    }
  }

  Future<void> saveNodeData(CentronicPlusNode node) async {
    return await _executeWithLock(() async {
      final nodeData = CpNodeBinaryData.fromNode(node);
      final macBytes = CpNodeBinaryData.macStringToBytes(node.mac);
      
      // Find existing entry
      TableIndexEntry? existingEntry;
      for (final entry in _index) {
        if (entry.type == TableEntryType.cpNode && entry.id.equals(macBytes)) {
          existingEntry = entry;
          break;
        }
      }
      
      int offset;
      if (existingEntry != null) {
        // Update existing entry timestamp
        existingEntry.updateTimestamp();
        offset = existingEntry.offset;
      } else {
        // Check if we have space for new entry (128-byte blocks)
        if (!_hasSpaceForEntry()) {
          throw StateError('Storage full: Cannot add new node');
        }
        
        // Create new entry with block allocation
        offset = _allocateBlock();
        final newEntry = TableIndexEntry(
          type: TableEntryType.cpNode,
          id: macBytes,
          offset: offset,
        );
        _indexInsert(newEntry);
      }
      
      // Save index and header
      await _saveHeader();
      // For new entries, use full index save (structure change)
      if (existingEntry == null) {
        await _saveIndex(); // Index structure changed, need full save
      } else {
        await _saveIndex(); // Just timestamp update, can use incremental
      }
      // Write data
      final data = nodeData.serialize();
      await _writeDataEntry(offset, data);
      
      // Update table size in header (total used space)
      final stats = getStorageStats();
      _header!.lengthOfTable = stats['usedSpace'];
      
      dev.log("Saved node ${node.mac} at offset $offset", name: 'CPBinaryStore');
    });
  }

  Future<bool> removeNodeData(String mac) async {
    return await _executeWithLock(() async {
      final macBytes = CpNodeBinaryData.macStringToBytes(mac);
      
      // Find and remove entry
      TableIndexEntry? entryToRemove;
      for (final entry in _index) {
        if (entry.type == TableEntryType.cpNode && entry.id.equals(macBytes)) {
          entryToRemove = entry;
          break;
        }
      }
      
      if (entryToRemove != null) {
        entryToRemove.markDirty();
        entryToRemove.type = TableEntryType.none;

        await _saveIndex(); // Index structure changed, need full save
        await _saveHeader();
        dev.log("Removed node $mac from index", name: 'CPBinaryStore');
        return true;
      }
      
      return false;
    });
  }

  /// Clear all data from the device storage
  Future<void> clearAllData() async {
    return await _executeWithLock(() async {
      // Create empty header
      _header = StorageHeader.empty(_deviceId);
      
      for(final entry in _index) {
        entry.markDirty();
        entry.type = TableEntryType.none;
      }

      _header?.lengthOfIndex = 0;
      _header?.lengthOfTable = 0;
      _index.clear();
      
      await _saveHeader();
      await _saveIndex();

      await _cache.synchronizeCache();
      
      dev.log("Cleared all binary data", name: 'CPBinaryStore');
    });
  }

  /// Helper method to format ID for logging
  String _formatId(List<int> id) {
    return id.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  // =================================
  // GROUP MANAGEMENT (TYPE=3)
  // =================================

  /// Store a group entry (TYPE=3)
  Future<bool> storeGroup({
    required int id,
    required String name,
    required List<int> cpGroup,
    required List<int> cGroup,
  }) async {
    return await _executeWithLock(() async {
      final groupData = CCGroup(
        id: id,
        name: name,
        cpGroup: cpGroup,
        cGroup: cGroup,
      );

      // Check if group already exists (by ID)
      final existingIndex = _index.indexWhere((entry) =>
          entry.type == TableEntryType.group && 
          entry.id.equals([...List.filled(7, 0), id])); // padded id

      if (existingIndex >= 0) {
        // Update existing group and timestamp
        final existingEntry = _index[existingIndex];
        existingEntry.updateTimestamp();
        final offset = existingEntry.offset;
        await _writeDataEntry(offset, groupData.serialize());
        await _saveHeader(); // Update global timestamp
        await _saveIndex(); // Update index with new timestamp
        
        dev.log("Updated group: ${groupData.idAsString}", name: 'CPBinaryStore');
        return true;
      } else {
        // Store new group - check space first
        if (!_hasSpaceForEntry()) {
          dev.log("No space available for group storage", name: 'CPBinaryStore');
          return false;
        }

        final offset = _allocateBlock();

        // Write group data
        await _writeDataEntry(offset, groupData.serialize());
        
        // Add to index
        final indexEntry = TableIndexEntry(
          type: TableEntryType.group,
          id: [...List.filled(7, 0), id],
          offset: offset,
        );
        
        _indexInsert(indexEntry);
        await _saveIndex(); // Index structure changed, need full save
        await _saveHeader(); // Update timestamp
        
        dev.log("Stored new group: ${groupData.idAsString}", name: 'CPBinaryStore');
        return true;
      }
    });
  }

  /// Get group by ID
  Future<CCGroup?> getGroupById(List<int> id) async {
    try {
      final indexEntry = _index.firstWhere(
        (entry) => entry.type == TableEntryType.group && entry.id.equals(id),
        orElse: () => throw StateError('Group not found'),
      );

      final data = await _readDataEntry(indexEntry.offset, CCGroup.ENTRY_SIZE);
      if (data == null) {
        dev.log("Failed to read group data for ID: ${id.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}", name: 'CPBinaryStore');
        return null;
      }

      final groupData = CCGroup.deserialize(data);
      dev.log("Retrieved group: ${groupData.idAsString}", name: 'CPBinaryStore');
      return groupData;
    } catch (e) {
      dev.log("Group not found or error: $e", name: 'CPBinaryStore');
      return null;
    }
  }

  /// Get all groups
  Future<List<CCGroup>> getAllGroups() async {
    dev.log("Retrieving all groups from binary store", name: 'CPBinaryStore.getAllGroups');
    try {
      final groups = <CCGroup>[];
      
      for (final entry in _index) {
        if (entry.type == TableEntryType.group) {
          final data = await _readDataEntry(entry.offset, CCGroup.ENTRY_SIZE);
          if (data != null) {
            final groupData = CCGroup.deserialize(data);
            groups.add(groupData);
          }
        }
      }
      
      dev.log("Retrieved ${groups.length} groups", name: 'CPBinaryStore.getAllGroups');
      return groups;
    } catch (e) {
      dev.log("Error retrieving groups: $e", name: 'CPBinaryStore.getAllGroups');
      return [];
    }
  }

  /// Remove group by ID
  Future<bool> removeGroupById(List<int> id) async {
    return await _executeWithLock(() async {
      // Find and remove entry
      TableIndexEntry? entryToRemove;
      for (final entry in _index) {
        if (entry.type == TableEntryType.group && entry.id.equals(id)) {
          entryToRemove = entry;
          break;
        }
      }
      
      if (entryToRemove != null) {
        entryToRemove.markDirty();
        entryToRemove.type = TableEntryType.none;

        await _saveIndex(); // Index structure changed, need full save
        await _saveHeader();
        dev.log("Removed group: ${id.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}", name: 'CPBinaryStore');
        return true;
      }
      
      return false;
    });
  }

  Future<bool> removeAllGroups() async {
    return await _executeWithLock(() async {
      for (final entry in _index) {
        if (entry.type == TableEntryType.group) {
          entry.markDirty();
          entry.type = TableEntryType.none;
        }
      }
      
      await _saveIndex(); // Index structure changed, need full save
      await _saveHeader();
      dev.log("Removed all groups", name: 'CPBinaryStore');
      return true;
    });
  }


  Future<int> nextUnusedGroupId() async {
    final groups = await getAllGroups();
    final allIds = groups.map((g) => g.id).toSet();
    int gId = 1;
    while (allIds.contains(gId)) {
      gId++;
    }
    return gId;
  }

  // STRING MANAGEMENT (TYPE=4)
  
  /// Store a string entry (TYPE=4)
  Future<bool> storeString({
    required List<int> id,
    required String content,
  }) async {
    return await _executeWithLock(() async {
      final stringData = StringBinaryData.fromString(
        id: id,
        content: content,
      );

      // Check if string already exists (by ID)
      for (final entry in _index) {
        if (entry.type == TableEntryType.string && 
            entry.id.equals(id)) {

          // Update existing string and timestamp
          entry.updateTimestamp();
          final offset = entry.offset;
          await _writeDataEntry(offset, stringData.serialize());
          await _saveHeader(); // Update global timestamp
          await _saveIndex(); // Update index with new timestamp

          dev.log("Updated string: ${_formatId(id)}", name: 'CPBinaryStore');
          return true;
        }
      }
      
      // Store new string - check space first
      if (!_hasSpaceForEntry()) {
        dev.log("No space available for string storage", name: 'CPBinaryStore');
        return false;
      }

      final offset = _allocateBlock(); // _allocateBlock() returns byte offset directly
      
      // Write string data
      await _writeDataEntry(offset, stringData.serialize());
      
      // Add to index
      _indexInsert(TableIndexEntry(
        type: TableEntryType.string,
        id: id,
        offset: offset,
      ));
      
      await _saveIndex(); // Index structure changed, need full save
      await _saveHeader(); // Update timestamp

      dev.log("Stored string: ${_formatId(id)} - '$content'", name: 'CPBinaryStore');
      return true;
    });
  }

  /// Retrieve string by ID
  Future<StringBinaryData?> getStringById(List<int> id) async {
    try {
      final indexEntry = _index.firstWhere(
        (entry) => entry.type == TableEntryType.string && entry.id.equals(id),
        orElse: () => throw StateError('String not found'),
      );

      // Read data block (strings use variable length, so read a reasonable maximum)
      final data = await _readDataEntry(indexEntry.offset, BLOCK_SIZE);
      if (data != null) {
        final stringData = StringBinaryData.deserialize(data);
        dev.log("Retrieved string: ${_formatId(id)} - '${stringData.content}'", name: 'CPBinaryStore');
        return stringData;
      }

      return null;
    } catch (e) {
      dev.log("String not found: ${id.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}", name: 'CPBinaryStore');
      return null;
    }
  }

  /// Get all strings
  Future<List<StringBinaryData>> getAllStrings() async {
    try {
      final strings = <StringBinaryData>[];
      
      for (final entry in _index) {
        if (entry.type == TableEntryType.string) {
          final data = await _readDataEntry(entry.offset, BLOCK_SIZE);
          if (data != null) {
            strings.add(StringBinaryData.deserialize(data));
          }
        }
      }
      
      dev.log("Retrieved ${strings.length} strings", name: 'CPBinaryStore');
      return strings;
    } catch (e) {
      dev.log("Error retrieving strings: $e", name: 'CPBinaryStore');
      return [];
    }
  }

  /// Remove string by ID
  Future<bool> removeStringById(List<int> id) async {
    try {
      final indexToRemove = _index.indexWhere((entry) =>
          entry.type == TableEntryType.string && 
          entry.id.equals(id));

      if (indexToRemove >= 0) {
        // Remove from index (simple storage doesn't use explicit block freeing)
        _index.removeAt(indexToRemove);
        await _saveIndex(); // Index structure changed, need full save
        await _saveHeader(); // Update timestamp

        dev.log("Removed string: ${id.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}", name: 'CPBinaryStore');
        return true;
      }

      dev.log("String not found for removal: ${id.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}", name: 'CPBinaryStore');
      return false;
    } catch (e) {
      dev.log("Error removing string: $e", name: 'CPBinaryStore');
      return false;
    }
  }

  // =================================
  // BULK OPERATIONS (Performance Optimized)
  // =================================

  /// Generic bulk store operation for any serializable data type
  /// Only writes header/index once at the end for maximum performance
  Future<List<bool>> bulkStore<T>({
    required List<T> items,
    required TableEntryType entryType,
    required List<int> Function(T item) getItemId,
    required List<int> Function(T item) serializeItem,
    required int itemSize,
  }) async {
    return await _executeWithLock(() async {
      final results = <bool>[];
      final newIndexEntries = <TableIndexEntry>[];
      final updates = <int, List<int>>{}; // offset -> data
      
      try {
        dev.log("Starting bulk store of ${items.length} ${entryType.name} entries", name: 'CPBinaryStore');
        
        for (final item in items) {
          try {
            final itemId = getItemId(item);
            final serializedData = serializeItem(item);
            
            // Skip size check for variable-size entries (itemSize = -1)
            if (itemSize > 0 && serializedData.length != itemSize) {
              dev.log("Item size mismatch: expected $itemSize, got ${serializedData.length}", name: 'CPBinaryStore');
              results.add(false);
              continue;
            }
            
            // Check if item already exists (by ID)
            var existingEntryIndex = -1;
            for (int i = 0; i < _index.length; i++) {
              if (_index[i].type == entryType && _index[i].id.equals(itemId)) {
                existingEntryIndex = i;
                break;
              }
            }
            
            if (existingEntryIndex >= 0) {
              // Update existing item and timestamp
              _index[existingEntryIndex].updateTimestamp();
              final offset = _index[existingEntryIndex].offset;
              updates[offset] = serializedData;
              results.add(true);
            } else {
              // Store new item - first try to reuse a deleted entry (TableEntryType.none)
              var reuseEntryIndex = -1;
              for (int i = 0; i < _index.length; i++) {
                if (_index[i].type == TableEntryType.none) {
                  reuseEntryIndex = i;
                  break;
                }
              }
              
              if (reuseEntryIndex >= 0) {
                // Reuse existing entry marked as deleted
                final reuseEntry = _index[reuseEntryIndex];
                reuseEntry.type = entryType;
                reuseEntry.id = List.from(itemId);
                reuseEntry.updateTimestamp();
                reuseEntry.markDirty();
                
                final offset = reuseEntry.offset;
                updates[offset] = serializedData;
                
                dev.log("Reusing deleted entry at index $reuseEntryIndex for ${entryType.name}", name: 'CPBinaryStore');
                results.add(true);
              } else {
                // No free entry found, check space for new entry
                if (_nextFreeBlock >= TOTAL_BLOCKS) {
                  dev.log("No space available for bulk storage", name: 'CPBinaryStore');
                  results.add(false);
                  continue;
                }
                
                final offset = _allocateBlock(); // _allocateBlock() returns byte offset directly
                updates[offset] = serializedData;
                
                // Create new index entry and add to the end
                final newEntry = TableIndexEntry(
                  type: entryType,
                  id: itemId,
                  offset: offset,
                );
                newIndexEntries.add(newEntry);
                _indexInsert(newEntry); // Add to in-memory index immediately
                
                dev.log("Added new entry at end of index for ${entryType.name}", name: 'CPBinaryStore');
                results.add(true);
              }
            }
          } catch (e) {
            dev.log("Error processing bulk item: $e", name: 'CPBinaryStore');
            results.add(false);
          }
        }
        
        // Perform all data writes
        dev.log("Writing ${updates.length} data blocks...", name: 'CPBinaryStore');
        for (final entry in updates.entries) {
          await _writeDataEntry(entry.key, entry.value);
        }
        
        // Add new index entries in batch
        if (newIndexEntries.isNotEmpty) {
          dev.log("Added ${newIndexEntries.length} new index entries", name: 'CPBinaryStore');
        }
        
        await _saveIndex();
        await _saveHeader(); // Update timestamp
        
        final successCount = results.where((r) => r).length;
        dev.log("Bulk store completed: $successCount/${items.length} successful", name: 'CPBinaryStore');
        
        return results;
      } catch (e) {
        dev.log("Error in bulk store operation: $e", name: 'CPBinaryStore');
        return List.filled(items.length, false);
      }
    });
  }

  /// Bulk store cpNodes (convenience method)
  Future<List<bool>> bulkStoreCpNodes(List<CentronicPlusNode> nodes) async {
    return await bulkStore<CentronicPlusNode>(
      items: nodes,
      entryType: TableEntryType.cpNode,
      getItemId: (node) => CpNodeBinaryData.macStringToBytes(node.mac),
      serializeItem: (node) => CpNodeBinaryData.fromNode(node).serialize(),
      itemSize: CpNodeBinaryData.ENTRY_SIZE,
    );
  }

  /// Bulk store groups (convenience method)  
  Future<List<bool>> bulkStoreGroups(List<Map<String, dynamic>> groups) async {
    return await bulkStore<Map<String, dynamic>>(
      items: groups,
      entryType: TableEntryType.group,
      getItemId: (group) => group['id'] as List<int>,
      serializeItem: (group) => CCGroup(
        id: group['id'].last as int,
        name: group['name'] as String,
        cpGroup: group['cpGroup'] as List<int>,
        cGroup: group['cGroup'] as List<int>,
      ).serialize(),
      itemSize: CCGroup.ENTRY_SIZE,
    );
  }

  /// Bulk store strings (convenience method)
  Future<List<bool>> bulkStoreStrings(List<Map<String, dynamic>> strings) async {
    return await bulkStore<Map<String, dynamic>>(
      items: strings,
      entryType: TableEntryType.string,
      getItemId: (string) => string['id'] as List<int>,
      serializeItem: (string) => StringBinaryData.fromString(
        id: string['id'] as List<int>,
        content: string['content'] as String,
      ).serialize(),
      itemSize: -1, // Variable size for strings
    );
  }

  /// Bulk remove by IDs (convenience method for cleanup)
  Future<List<bool>> bulkRemove({
    required TableEntryType entryType,
    required List<List<int>> ids,
  }) async {
    final results = <bool>[];
    final indicesToRemove = <int>[];
    
    try {
      // Find all indices to remove
      for (final id in ids) {
        final indexToRemove = _index.indexWhere((entry) =>
            entry.type == entryType && entry.id.equals(id));
        
        if (indexToRemove >= 0) {
          indicesToRemove.add(indexToRemove);
          results.add(true);
        } else {
          results.add(false);
        }
      }
      
      // Remove in reverse order to maintain correct indices
      indicesToRemove.sort((a, b) => b.compareTo(a));
      for (final index in indicesToRemove) {
        _index.removeAt(index);
      }
      
      // Save index and header ONCE at the end
      if (indicesToRemove.isNotEmpty) {
        await _saveIndex(); // Index structure changed, need full save
        await _saveHeader();
      }
      
      dev.log("Bulk removed ${indicesToRemove.length}/${ids.length} ${entryType.name} entries", name: 'CPBinaryStore');
      return results;
    } catch (e) {
      dev.log("Error in bulk remove operation: $e", name: 'CPBinaryStore');
      return List.filled(ids.length, false);
    }
  }

  // =================================
  // UTILITY METHODS
  // =================================

  /// Clear local cache and force reload from device
  Future<void> clearCache() async {
    try {
      await _cache.clearCache();
      dev.log("Cache cleared, reinitializing from device", name: 'CPBinaryStore');
      
      // Reload everything from device
      await _loadHeader();
      await _loadIndex();
      
      dev.log("Reinitialized from device after cache clear", name: 'CPBinaryStore');
    } catch (e) {
      dev.log("Error clearing cache: $e", name: 'CPBinaryStore');
    }
  }

  /// Check if cache is valid
  Future<bool> isCacheValid() async {
    return await _cache.isCacheValid();
  }

  /// Perform granular cache synchronization
  /// Returns list of updated entry IDs
  Future<List<String>> synchronizeCache() async {
    try {
      final updatedEntries = await _cache.synchronizeCache();
      
      if (updatedEntries.isNotEmpty) {
        // Reload header and index after synchronization
        await _loadHeader(cacheFirst: true);
        await _loadIndex(cacheFirst: true);
        
        dev.log("Manual sync completed: ${updatedEntries.length} entries updated", name: 'CPBinaryStore');
      }
      
      return updatedEntries;
    } catch (e) {
      dev.log("Error in manual cache sync: $e", name: 'CPBinaryStore');
      return [];
    }
  }

  Future<void> onUpdate() async {
    await validateCache();
  }
}