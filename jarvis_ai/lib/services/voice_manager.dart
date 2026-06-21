import 'voice_manager_stub.dart'
    if (dart.library.html) 'voice_manager_web.dart';

abstract class VoiceManager {
  factory VoiceManager() => getVoiceManager();
  
  bool get isSupported;
  bool get isListening;
  
  void init({
    required Function(String text) onResult,
    required Function() onEnd,
    required Function(String error) onError,
  });
  
  void startListening();
  void stopListening();
  void speak(String text);
  void stopSpeaking();
}
