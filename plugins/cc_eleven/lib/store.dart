// import 'dart:developer' as dev;


// /// Abstract base class for CC Eleven storage implementations
// /// Defines the core interface and common functionality for binary storage systems
// /// 
// /// Generic types:
// /// - NODE_T: Type for node objects (e.g., CentronicPlusNode)
// /// - CP_T: Type for centronic plus controller (e.g., CentronicPlus)
// /// - GROUP_T: Type for group objects
// /// - STRING_T: Type for string objects
// abstract class CCElevenStoreBase<NODE_T, CP_T, GROUP_T, STRING_T> {
//   // Storage constants - can be overridden by implementations
//   static const int DEFAULT_STORAGE_SIZE = 32 * 1024; // 32KB
//   static const int DEFAULT_HEADER_SIZE = 36;
//   static const int DEFAULT_BLOCK_SIZE = 128;
  
//   // Storage configuration
//   int get storageSize => DEFAULT_STORAGE_SIZE;
//   int get headerSize => DEFAULT_HEADER_SIZE;
//   int get blockSize => DEFAULT_BLOCK_SIZE;
//   int get totalBlocks => storageSize ~/ blockSize;
  
//   // Internal state
//   late String deviceId;
//   // bool get isInitialized;
  
//   // Initialization
//   // Future<void> initializeTables(String cacheId);
  
//   // Header management
//   // Future<void> loadHeader({bool cacheFirst = false});
//   // Future<void> saveHeader();
  
//   // Index management
//   // Future<void> loadIndex({bool cacheFirst = false});
//   // Future<void> saveIndex();
//   // Future<void> saveIndexFull();
//   // Future<void> saveIndexIncremental();
  
//   // Lock management
//   // Future<T> executeWithLock<T>(Future<T> Function() operation);
//   // Future<T> executeRead<T>(Future<T> Function() operation);
//   // Map<String, dynamic> getLockStats();
  
//   // Storage space management
//   // int allocateBlock();
//   // bool hasSpaceForEntry();
//   Map<String, dynamic> getStorageStats();
//   // void initializeFreeBlocks();
  
//   // Data I/O operations
//   // Future<List<int>?> readDataEntry(int offset, int size, {bool? cacheFirst});
//   // Future<void> writeDataEntry(int offset, List<int> data);
  
//   // Node management - core operations with generic types
//   Future<NODE_T?> getNode(String mac, CP_T cp);
//   Future<List<NODE_T>> getAllNodes(CP_T cp);
//   Future<bool> removeAllNodes(String panId);
//   Future<bool> putNode(NODE_T node);
//   Future<bool> deleteNode(NODE_T node);
  
//   // Advanced node operations
//   Future<void> saveNodeData(NODE_T node);
//   Future<bool> removeNodeData(String mac);
  
//   // Group management with generic type
//   Future<bool> storeGroup({
//     required int id,
//     required String name,
//     required List<int> cpGroup,
//     required List<int> cGroup,
//   });
//   Future<GROUP_T?> getGroupById(List<int> id);
//   Future<List<GROUP_T>> getAllGroups();
//   Future<bool> removeGroupById(List<int> id);
  
//   // String management with generic type
//   Future<bool> storeString({
//     required List<int> id,
//     required String content,
//   });
//   Future<STRING_T?> getStringById(List<int> id);
//   Future<List<STRING_T>> getAllStrings();
//   Future<bool> removeStringById(List<int> id);
  
//   // Bulk operations for performance
//   Future<List<bool>> bulkStore<T>({
//     required List<T> items,
//     required TableEntryType entryType,
//     required List<int> Function(T item) getItemId,
//     required List<int> Function(T item) serializeItem,
//     required int itemSize,
//   });
  
//   Future<List<bool>> bulkStoreCpNodes(List<NODE_T> nodes);
//   Future<List<bool>> bulkStoreGroups(List<Map<String, dynamic>> groups);
//   Future<List<bool>> bulkStoreStrings(List<Map<String, dynamic>> strings);
//   Future<List<bool>> bulkRemove({
//     required TableEntryType entryType,
//     required List<List<int>> ids,
//   });
  
//   // Cache management
//   Future<void> validateCache();
//   Future<void> clearCache();
//   Future<bool> isCacheValid();
//   Future<List<String>> synchronizeCache();
  
//   // Utility operations
//   Future<void> clearAllData();

//   Future<void> onUpdate();
// }
