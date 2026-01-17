import 'package:uuid/uuid.dart';

class PairingService {
  static String generateDeviceId() {
    return const Uuid().v4();
  }

  static String generatePublicKey() {
    return const Uuid().v4(); // placeholder for real key
  }

  static String generateOtp() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
        .toString();
  }
}
