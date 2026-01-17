import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'protocol.dart';

class WebRTCConnection {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  /// Called when a ProtocolMessage is received
  Function(ProtocolMessage message)? onMessage;

  /// Called when a new ICE candidate is generated
  Function(RTCIceCandidate candidate)? onIceCandidate;

  WebRTCConnection();

  /* ===============================
     PEER CONNECTION
     =============================== */

  Future<void> initPeerConnection() async {
    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onIceCandidate = (candidate) {
      if (onIceCandidate != null) {
        onIceCandidate!(candidate);
      }
    };

    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };
  }

  /* ===============================
     DATA CHANNEL
     =============================== */

  Future<void> createDataChannel() async {
    final RTCDataChannelInit init = RTCDataChannelInit();
    init.ordered = true;

    _dataChannel =
        await _peerConnection!.createDataChannel('clipboard', init);

    _setupDataChannel();
  }

  void _setupDataChannel() {
    _dataChannel!.onMessage = (RTCDataChannelMessage msg) {
      if (msg.isBinary) return;

      final decoded = jsonDecode(msg.text);
      final protocolMsg = ProtocolMessage.fromJson(decoded);

      if (onMessage != null) {
        onMessage!(protocolMsg);
      }
    };
  }

  void sendMessage(ProtocolMessage message) {
    if (_dataChannel == null) return;

    final jsonStr = jsonEncode(message.toJson());
    _dataChannel!.send(RTCDataChannelMessage(jsonStr));
  }

  /* ===============================
     OFFER / ANSWER
     =============================== */

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<void> setRemoteDescription(
      RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }
}
