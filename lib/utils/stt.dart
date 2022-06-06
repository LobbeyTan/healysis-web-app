import 'dart:developer';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextController {
  late final SpeechToText stt;
  bool isListening = false;
  bool isAvailable = false;

  SpeechToTextController() {
    stt = SpeechToText();

    _init();
  }

  void _init() async => isAvailable = await stt.initialize();

  void listen(void Function(SpeechRecognitionResult) onSpeechResult) async {
    if (isAvailable && await stt.hasPermission && !isListening) {
      isListening = true;
      log("Controller is listening $isListening");
      stt.listen(onResult: onSpeechResult);
    }
  }

  void stop() async {
    if (isAvailable && await stt.hasPermission && isListening) {
      isListening = false;
      log("Controller is listening $isListening");
      stt.stop();
    }
  }
}
