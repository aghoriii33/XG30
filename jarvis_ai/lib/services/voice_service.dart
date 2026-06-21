import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'voice_manager.dart';

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
  final ApiService _apiService;
  late final VoiceManager _voiceManager;
  Timer? _timer;
  bool _initialized = false;

  VoiceService(this._apiService) : super(VoiceState()) {
    _voiceManager = VoiceManager();
  }

  void _initVoiceManager() {
    if (_initialized) return;
    _voiceManager.init(
      onResult: (text) {
        _handleSpeechResult(text);
      },
      onEnd: () {
        if (state.isListening) {
          state = state.copyWith(isListening: false, status: 'Tap to speak');
        }
      },
      onError: (error) {
        state = state.copyWith(
          isListening: false,
          status: 'Speech Error: Try typing or check mic',
        );
      },
    );
    _initialized = true;
  }

  void startVoiceSession() {
    _initVoiceManager();
    _voiceManager.stopSpeaking();
    _timer?.cancel();

    if (_voiceManager.isSupported) {
      state = VoiceState(
        isListening: true,
        status: "I'm listening... Speak now",
      );
      _voiceManager.startListening();
    } else {
      // Offline/Desktop simulation fallback that calls the backend
      state = VoiceState(
        isListening: true,
        status: "Simulating voice session... (Web Speech not supported)",
      );
      
      _timer = Timer(const Duration(seconds: 2), () {
        _handleSpeechResult("What is my spending starting from last month?");
      });
    }
  }

  void stopVoiceSession() {
    _timer?.cancel();
    _voiceManager.stopListening();
    _voiceManager.stopSpeaking();
    state = VoiceState();
  }

  void toggleListening() {
    if (state.isListening || state.isSpeaking) {
      stopVoiceSession();
    } else {
      startVoiceSession();
    }
  }

  void stopSpeaking() {
    _voiceManager.stopSpeaking();
    state = state.copyWith(
      isSpeaking: false,
      status: 'Ready for next command',
    );
  }

  Future<void> _handleSpeechResult(String text) async {
    state = state.copyWith(
      isListening: false,
      userText: text,
      status: "Processing voice command...",
    );

    try {
      final response = await _apiService.sendChatMessage(
        text,
        "gpt-5",
        [],
      );
      final reply = response['reply'] ?? "No response from AI.";
      
      state = state.copyWith(
        isSpeaking: true,
        botText: reply,
        status: "Speaking...",
      );

      _voiceManager.speak(reply);

      // Estimate speak duration
      final duration = (reply.length / 14).clamp(3.0, 12.0).toInt();
      _timer = Timer(Duration(seconds: duration), () {
        state = state.copyWith(
          isSpeaking: false,
          status: 'Tap mic to talk again',
        );
      });
    } catch (e) {
      state = state.copyWith(
        botText: "Sorry, I had trouble processing that: $e",
        status: "Connection error",
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voiceManager.stopSpeaking();
    super.dispose();
  }
}

final voiceServiceProvider = StateNotifierProvider<VoiceService, VoiceState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VoiceService(apiService);
});
