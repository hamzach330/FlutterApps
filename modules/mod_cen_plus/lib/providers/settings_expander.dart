part of '../module.dart';

class CPExpandSettings extends ChangeNotifier {
  bool expand = false;
  int tapCount = 0;

  void unlock () {
    tapCount++;
    if(tapCount >= 4) {
      expand = !expand;
      tapCount = 0;
      notifyListeners();
    }
  }
}
