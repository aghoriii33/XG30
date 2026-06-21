import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceState {
  final bool isListening;
  final bool isSpeaking;
  final String userText;
  final String botText;
  final String status;

  VoiceState({
    this.isListening = false,
    this.isSpeaking = false,
    this.userText = '',
    this.botText = '',
    this.status = 'Tap the microphone to start',
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isSpeaking,
    String? userText,
    String? botText,
    String? status,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      userText: userText ?? this.userText,
      botText: botText ?? this.botText,
      status: status ?? this.status,
    );
  }
}

class VoiceService extends StateNotifier<VoiceState> {
  VoiceService() : super(VoiceState());
  Timer? _simulationTimer;

  void startVoiceSession() {
    state = VoiceState(
      isListening: true,
      status: "Go ahead, I'm listening...",
    );
    
    // Simulate user speaking after 3 seconds
    _simulationTimer?.cancel();
    _simulationTimer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(
        isListening: false,
        isSpeaking: false,
        userText: "How much is my entire spending starting from last month?",
        status: "Processing query...",
      );
      
      // Simulate bot processing and then speaking after 1.5 seconds
      _simulationTimer = Timer(const Duration(milliseconds: 1500), () {
        state = state.copyWith(
          isSpeaking: true,
          status: "Speaking...",
          botText: "Your total spending last month was \$1,245.50. You spent \$420.30 on Food, \$180.20 on Transport, and \$350 on Utilities.",
        );
        
        // Stop speaking after 5 seconds
        _simulationTimer = Timer(const Duration(seconds: 5), () {
          state = state.copyWith(
            isSpeaking: false,
            status: "Waiting for reply...",
          );
        });
      });
    });
  }

  void stopVoiceSession() {
    _simulationTimer?.cancel();
    state = VoiceState();
  }

  void toggleListening() {
    if (state.isListening) {
      stopVoiceSession();
    } else {
      startVoiceSession();
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

final voiceServiceProvider = StateNotifierProvider<VoiceService, VoiceState>((ref) {
  return VoiceService();
});
