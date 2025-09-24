part of 'store.dart';

/// Lock states for storage concurrency control
enum StorageLockState {
  unlocked,           // No lock active
  lockedByUs,         // We hold the lock
  lockedByOther,      // Another participant holds the lock
  lockTimeout,        // Lock timeout occurred
}

/// Storage lock manager for concurrency control
class CPStorageLock {
  final CCEleven ccEleven;
  StorageLockState _currentState = StorageLockState.unlocked;
  
  // Operation queues
  final List<Future<void> Function()> _writeQueue = [];
  final List<Future<dynamic> Function()> _readQueue = [];
  bool _processingQueue = false;
  
  CPStorageLock(this.ccEleven);
  
  /// Get current lock state
  StorageLockState get currentState => _currentState;
  
  /// Check if we currently hold the lock
  bool get isLockedByUs => _currentState == StorageLockState.lockedByUs;
  
  /// Check if lock is available
  bool get isUnlocked => _currentState == StorageLockState.unlocked;
  
  /// Acquire exclusive lock
  Future<StorageLockState> acquireLock() async {
    try {
      final success = await ccEleven.lockUserData();
      
      if (success) {
        _currentState = StorageLockState.lockedByUs;
        dev.log("Successfully acquired storage lock", name: 'CPStorageLock');
      } else {
        _currentState = StorageLockState.lockedByOther;
        dev.log("Cannot acquire lock: already locked by another participant", name: 'CPStorageLock');
      }
      
      return _currentState;
    } catch (e) {
      dev.log("Error acquiring lock: $e", name: 'CPStorageLock');
      _currentState = StorageLockState.lockedByOther;
      return _currentState;
    }
  }
  
  /// Release lock
  Future<bool> releaseLock() async {
    try {
      if (_currentState != StorageLockState.lockedByUs) {
        dev.log("Cannot release lock: not locked by us (state: $_currentState)", name: 'CPStorageLock');
        return false;
      }
      
      // Release lock and commit data
      await ccEleven.commitUserData();
      _currentState = StorageLockState.unlocked;
      dev.log("Successfully released storage lock", name: 'CPStorageLock');
      return true;
      
    } catch (e) {
      dev.log("Error releasing lock: $e", name: 'CPStorageLock');
      return false;
    }
  }
  
  /// Execute write operation with lock
  Future<T> executeWrite<T>(Future<T> Function() operation) async {
    if (_currentState == StorageLockState.lockedByOther) {
      throw StateError('Cannot execute write: storage locked by another participant');
    }
    
    if (_currentState != StorageLockState.lockedByUs) {
      // Queue the operation
      final completer = Completer<T>();
      _writeQueue.add(() async {
        try {
          final result = await operation();
          completer.complete(result);
        } catch (e) {
          completer.completeError(e);
        }
      });
      
      // Start processing queue if not already running
      _processQueues();
      
      return completer.future;
    }
    
    // We have the lock, execute immediately
    return await operation();
  }
  
  /// Execute read operation with lock awareness
  Future<T> executeRead<T>(Future<T> Function() operation) async {
    if (_currentState == StorageLockState.lockedByOther) {
      // For reads, we can still try but should be aware of potential inconsistency
      dev.log("Warning: Reading while locked by another participant", name: 'CPStorageLock');
    }
    
    if (_currentState != StorageLockState.lockedByUs && _writeQueue.isNotEmpty) {
      // Queue read operations if writes are pending
      final completer = Completer<T>();
      _readQueue.add(() async {
        try {
          final result = await operation();
          completer.complete(result);
        } catch (e) {
          completer.completeError(e);
        }
      });
      
      return completer.future;
    }
    
    // Execute immediately
    return await operation();
  }
  
  /// Process queued operations
  Future<void> _processQueues() async {
    if (_processingQueue) return;
    _processingQueue = true;
    
    try {
      while (_writeQueue.isNotEmpty || _readQueue.isNotEmpty) {
        // Acquire lock for writes
        if (_writeQueue.isNotEmpty) {
          final lockState = await acquireLock();
          if (lockState != StorageLockState.lockedByUs) {
            dev.log("Cannot process write queue: failed to acquire lock", name: 'CPStorageLock');
            break;
          }
          
          // Process all write operations
          while (_writeQueue.isNotEmpty) {
            final operation = _writeQueue.removeAt(0);
            await operation();
          }
          
          // Release lock after all writes
          await releaseLock();
        }
        
        // Process read operations
        while (_readQueue.isNotEmpty) {
          final operation = _readQueue.removeAt(0);
          await operation();
        }
      }
    } finally {
      _processingQueue = false;
    }
  }
  
  /// Dispose lock manager
  void dispose() {
    // Force release if we hold the lock
    if (_currentState == StorageLockState.lockedByUs) {
      ccEleven.commitUserData();
      _currentState = StorageLockState.unlocked;
    }
    
    // Clear queues
    _writeQueue.clear();
    _readQueue.clear();
  }
  
  /// Get lock statistics
  Map<String, dynamic> getLockStats() {
    return {
      'currentState': _currentState.toString(),
      'writeQueueLength': _writeQueue.length,
      'readQueueLength': _readQueue.length,
      'processingQueue': _processingQueue,
    };
  }
}
