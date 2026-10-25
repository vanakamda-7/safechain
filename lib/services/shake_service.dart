import 'package:flutter/foundation.dart';
import 'package:shake/shake.dart';

class ShakeService {
  ShakeDetector? _detector;
  int _shakeCount = 0;
  DateTime? _firstShakeTime;

  void startListening({
    required VoidCallback onShakeDetected,
  }) {
    _detector = ShakeDetector.waitForStart(
      onPhoneShake: (_) {
        final DateTime now = DateTime.now();

        if (_firstShakeTime == null ||
            now.difference(_firstShakeTime!).inSeconds > 3) {
          _shakeCount = 0;
          _firstShakeTime = now;
        }

        _shakeCount++;

        if (_shakeCount >= 3) {
          _shakeCount = 0;
          onShakeDetected();
        }
      },
    );

    _detector!.startListening();
  }

  void stopListening() {
    _detector?.stopListening();
    _detector = null;
  }
}
