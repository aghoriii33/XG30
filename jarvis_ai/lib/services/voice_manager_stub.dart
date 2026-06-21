import 'voice_manager.dart';

class StubVoiceManager implements VoiceManager {
  @override
  bool get isSupported => false;

  @override
  bool get isListening => false;

  @override
  void init({
    required Function(String text) onResult,
    required Function() onEnd,
    required Function(String error) onError,
  }) {}

  @override
  void startListening() {}

  @override
  void stopListening() {}

  @override
  void speak(String text) {}

  @override
  void stopSpeaking() {}
}

VoiceManager getVoiceManager() => StubVoiceManager();
