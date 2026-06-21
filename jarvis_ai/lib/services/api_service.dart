import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';

class ChatMessageData {
  final String role;
  final String content;

  ChatMessageData({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ApiService {
  final Ref _ref;
  final String _baseUrl = 'http://127.0.0.1:8000';

  ApiService(this._ref);

  Future<Map<String, dynamic>> sendChatMessage(String message, String model, List<ChatMessageData> history) async {
    final auth = _ref.read(authServiceProvider.notifier);
    final headers = {
      'Content-Type': 'application/json',
      if (auth.token.isNotEmpty) 'Authorization': 'Bearer ${auth.token}',
    };

    final body = jsonEncode({
      'message': message,
      'model': model.toLowerCase(),
      'history': history.map((e) => e.toJson()).toList(),
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback offline simulator
      await Future.delayed(const Duration(milliseconds: 1200)); // Simulate network latency
      return {
        'reply': _getLocalMockResponse(message, model),
        'model_used': '$model (Local Offline Fallback)'
      };
    }
  }

  Future<String> createStripeCheckout() async {
    final auth = _ref.read(authServiceProvider.notifier);
    final headers = {
      'Content-Type': 'application/json',
      if (auth.token.isNotEmpty) 'Authorization': 'Bearer ${auth.token}',
    };

    final body = jsonEncode({
      'success_url': 'https://jarvis-pro-success.web.app',
      'cancel_url': 'https://jarvis-pro-cancel.web.app',
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/stripe/create-checkout'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] ?? '';
      }
    } catch (e) {
      // Fallback checkout URL simulation
      return 'https://checkout.stripe.com/pay/mock_session_12345?success=true';
    }
    return '';
  }

  String _getLocalMockResponse(String message, String model) {
    final msg = message.toLowerCase();
    
    if (msg.contains('spending') || msg.contains('spending starting from last month')) {
      return "Based on my analysis, your total spending last month was **\$1,245.50**.\n\n"
             "Here is the breakdown:\n"
             "* 🍔 **Food & Dining**: \$420.30\n"
             "* 🚗 **Transport**: \$180.20\n"
             "* 🏠 **Utilities**: \$350.00\n"
             "* 🍿 **Entertainment**: \$295.00\n\n"
             "This is **12% higher** than your average. Let me know if you would like me to draft a savings plan!";
    }

    if (msg.contains('ui inspiration') || msg.contains('color palettes')) {
      return "Here are some gorgeous color schemes for your premium AI app:\n\n"
             "1. **Midnight Neon**: `#0B0C10` (Dark background), `#1F2833` (Card body), `#66FCF1` (Bright Cyan accent), `#45A29E` (Slate green).\n"
             "2. **Cyber Glass**: Deep translucent navy overlays with glowing magenta/purple neon details (`#8A2BE2`, `#FF007F`).\n\n"
             "Would you like me to generate a custom Flutter widget for this?";
    }

    switch (model.toLowerCase()) {
      case 'grok':
        return "Grok here! Regarding '$message': Honestly, it's a bit simple. But since I'm running in your local Flutter offline mode, I'll give it an A- for effort. What else is on your mind?";
      case 'claude':
        return "I have analyzed your inquiry regarding '$message'. To explore this effectively, we should first organize the priorities: state management structure, styling tokens, and mock api fallbacks. Please let me know how you wish to proceed.";
      case 'gemini':
        return "Hi Michael! Let's brainstorm on: '$message'. 🌟 I've noted your preference for premium glassmorphic cards and dark UI layouts. I'm ready to assist with details!";
      case 'deepseek':
        return "DeepSeek model response:\n```dart\n// Generated for '$message'\nvoid runJarvis() {\n  print('Optimized JARVIS pipeline active.');\n}\n```";
      default:
        return "JARVIS here. Regarding '$message': My local simulator is running fine! To unlock full GPT-5 reasoning, please start the FastAPI backend and configure your API key.";
    }
  }

  Future<bool> saveCustomApiKeys(String openaiKey, String geminiKey) async {
    final auth = _ref.read(authServiceProvider.notifier);
    final headers = {
      'Content-Type': 'application/json',
      if (auth.token.isNotEmpty) 'Authorization': 'Bearer ${auth.token}',
    };
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/settings/keys'),
        headers: headers,
        body: jsonEncode({
          'openai_key': openaiKey,
          'gemini_key': geminiKey,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getCustomApiKeysStatus() async {
    final auth = _ref.read(authServiceProvider.notifier);
    final headers = {
      if (auth.token.isNotEmpty) 'Authorization': 'Bearer ${auth.token}',
    };
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/keys'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Fallback
    }
    return {
      'openai_key_configured': false,
      'gemini_key_configured': false,
    };
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
