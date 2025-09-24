import 'dart:async';

import 'package:mt_interface/const.dart';
import 'package:mt_interface/endpoint.dart';
import 'package:mt_interface/message.dart';

abstract class MTReaderWriter<Message_T extends MTMessageInterface, RawMessage_T, Self_T> {
  MTEndpoint? _endpoint;
  
  final StreamController<Self_T> updateStream = StreamController<Self_T>.broadcast();
  void notifyListeners();

  set endpoint (MTEndpoint newEndpoint) => _endpoint = newEndpoint;
  
  MTEndpoint get endpoint => _endpoint == null
    ? throw MTEndpointException("Endpoint not set")
    : _endpoint!; 

  void read(RawMessage_T data);

  Future<void> writeMessage(Message_T message);

  // Future<T?> writeMessageWithResponse<T extends Message_T>(T message);

  void closeEndpoint() {
    endpoint.close();
  }
}