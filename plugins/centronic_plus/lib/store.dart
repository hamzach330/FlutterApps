part of 'centronic_plus.dart';

abstract class CPStore {
  Future<CentronicPlusNode?> getNode(String mac, CentronicPlus cp);

  Future<List<CentronicPlusNode>> getAllNodes(CentronicPlus cp);

  Future<bool> removeAllNodes(String panId);

  Future<bool> putNode (CentronicPlusNode node);

  Future<bool> deleteNode (CentronicPlusNode node);
}
