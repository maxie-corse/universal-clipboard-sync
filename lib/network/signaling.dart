import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingService {
  WebSocketChannel? _channel;

  void connect(String roomId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.9.100:8080'),
    );

    _send({
      'type': 'join',
      'roomId': roomId,
    });
  }

  void _send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  void sendOffer(String sdp) {
    _send({
      'type': 'offer',
      'sdp': sdp,
    });
  }

  void sendAnswer(String sdp) {
    _send({
      'type': 'answer',
      'sdp': sdp,
    });
  }

  void sendIceCandidate(Map<String, dynamic> candidate) {
    _send({
      'type': 'ice-candidate',
      'candidate': candidate,
    });
  }

  Stream<Map<String, dynamic>> get messages =>
      _channel!.stream.map((event) => jsonDecode(event));

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
