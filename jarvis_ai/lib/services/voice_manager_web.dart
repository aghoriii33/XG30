import 'dart:html' as html;
import 'voice_manager.dart';

class WebVoiceManager implements VoiceManager {
  html.SpeechRecognition? _recognition;
  bool _isListening = false;
  
  @override
  bool get isSupported => html.SpeechRecognition.supported;

  @override
  bool get isListening => _isListening;

  @override
  void init({
    required Function(String text) onResult,
    required Function() onEnd,
    required Function(String error) onError,
  }) {
    if (isSupported) {
      try {
        _recognition = html.SpeechRecognition()
          ..continuous = false
          ..interimResults = false
          ..lang = 'en-US';

        _recognition!.onResult.listen((event) {
          final List<dynamic>? results = event.results;
          if (results != null && results.isNotEmpty) {
            final dynamic recognitionResult = results[0];
            final dynamic alternative = recognitionResult.item(0);
            if (alternative != null) {
              final String? transcript = alternative.transcript;
              if (transcript != null) {
                onResult(transcript);
              }
            }
          }
        });

        _recognition!.onEnd.listen((event) {
          _isListening = false;
          onEnd();
        });

        _recognition!.onError.listen((event) {
          onError('Speech recognition error');
          _isListening = false;
          onEnd();
        });
      } catch (e) {
        onError('Failed to initialize speech recognition: $e');
      }
    }
  }

  @override
  void startListening() {
    if (isSupported && _recognition != null && !_isListening) {
      try {
        _recognition!.start();
        _isListening = true;
      } catch (e) {
        // Handle double start error
      }
    }
  }

  @override
  void stopListening() {
    if (isSupported && _recognition != null && _isListening) {
      try {
        _recognition!.stop();
        _isListening = false;
      } catch (e) {
        // Ignore
      }
    }
  }

  @override
  void speak(String text) {
    try {
      final synthesis = html.window.speechSynthesis;
      if (synthesis != null) {
        synthesis.cancel();
        final utterance = html.SpeechSynthesisUtterance(text)
          ..lang = 'en-US'
          ..rate = 1.0;
        synthesis.speak(utterance);
      }
    } catch (e) {
      // Ignore speak errors
    }
  }

  @override
  void stopSpeaking() {
    try {
      html.window.speechSynthesis?.cancel();
    } catch (e) {
      // Ignore
    }
  }
}

VoiceManager getVoiceManager() => WebVoiceManager();
