part of '../module.dart';

class OtaProgressProvider extends ChangeNotifier {
  int             _current = 0;
  List<Uint8List> _data    = [];
  int             _length  = 0;
  bool            _done    = false;

  set length(int value) {
    _length = value;
    notifyListeners();
  }

  set current(int value) {
    _current = value;
    notifyListeners();
  }

  set data(List<Uint8List> value) {
    _data = value;
    notifyListeners();
  }

  set done(bool value) {
    _done = value;
    notifyListeners();
  }

  int get current => _current;
  int get length => _length;
  bool get done => _done;
  List<Uint8List> get data => _data;
}