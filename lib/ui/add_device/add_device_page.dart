import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/pairing_service.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  late final String deviceId;
  late final String publicKey;
  late final String otp;

  @override
  void initState() {
    super.initState();
    deviceId = PairingService.generateDeviceId();
    publicKey = PairingService.generatePublicKey();
    otp = PairingService.generateOtp();
  }

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'device_id': deviceId,
      'public_key': publicKey,
      'otp': otp,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add Device')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: payload,
            size: 250,
          ),
          const SizedBox(height: 16),
          Text('OTP: $otp'),
        ],
      ),
    );
  }
}

