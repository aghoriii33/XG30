import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/encryption_service.dart';
import '../services/auth_service.dart';
import '../widgets/message_bubble.dart';
import 'settings_screen.dart';

// Chat state structure
class ChatState {
  final List<ChatMessageData> messages;
  final bool isLoading;
  final String activeModel;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.activeModel = 'ChatGPT-5 Pro',
  });

  ChatState copyWith({
    List<ChatMessageData>? messages,
    bool? isLoading,
    String? activeModel,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      activeModel: activeModel ?? this.activeModel,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _apiService;
  final Ref _ref;

  ChatNotifier(this._apiService, this._ref)
      : super(ChatState(messages: [
          ChatMessageData(
            role: 'assistant',
            content: 'Hello! I am JARVIS. Choose a model above and start chatting.',
          ),
        ]));

  void changeModel(String newModel) {
    state = state.copyWith(activeModel: newModel);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final user = _ref.read(authServiceProvider);
    final userSecretKey = user?.uid ?? 'guest-uid';
    final e2eeEnabled = _ref.read(e2eeProvider);

    final String contentToSend = e2eeEnabled
        ? EncryptionService.encrypt(text, userSecretKey)
        : text;

    final userMsg = ChatMessageData(role: 'user', content: text);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final List<ChatMessageData> encryptedHistory = [];
      for (final msg in state.messages.sublist(0, state.messages.length - 1)) {
        final encContent = e2eeEnabled
            ? (msg.content.startsWith("E2EE:") ? msg.content : EncryptionService.encrypt(msg.content, userSecretKey))
            : msg.content;
        encryptedHistory.add(ChatMessageData(role: msg.role, content: encContent));
      }

      final response = await _apiService.sendChatMessage(
        contentToSend,
        state.activeModel,
        encryptedHistory,
      );

      String reply = response['reply'] ?? 'Failed to get response';

      if (e2eeEnabled && reply.startsWith("E2EE:")) {
        reply = EncryptionService.decrypt(reply, userSecretKey);
      }

      final botMsg = ChatMessageData(role: 'assistant', content: reply);
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (e) {
      final botMsg = ChatMessageData(role: 'assistant', content: 'Error communicating with backend: $e');
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    }
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatNotifier(apiService, ref);
});

class ChatScreen extends ConsumerWidget {
  ChatScreen({super.key});

  final TextEditingController _textController = TextEditingController();
  final List<String> _models = [
    'ChatGPT-5 Pro',
    'Claude 3.5 Sonnet (Thinking)',
    'Gemini 3.1 Pro (High)',
    'DeepSeek-V3',
    'Grok 2.0'
  ];
  final List<String> _suggestions = [
    'I need some UI inspiration...',
    'Show me color palettes...',
    'Write a Flutter animation...',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "JARVIS Chat",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment_rounded, color: Colors.amber),
            onPressed: () async {
              final checkoutUrl = await ref.read(apiServiceProvider).createStripeCheckout();
              // Show dialog with checkout link
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF0F172A),
                    title: Text(
                      'Upgrade to Premium',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Ready to upgrade to JARVIS Pro subscription for unlimited access?',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Route mock redirect
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Redirecting to checkout: $checkoutUrl')),
                          );
                        },
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Scrollable Model Selector Pill List
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF0C0E14),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _models.length,
                itemBuilder: (context, index) {
                  final model = _models[index];
                  final isSelected = chatState.activeModel == model;
                  return GestureDetector(
                    onTap: () => chatNotifier.changeModel(model),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          model,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // E2EE Secured Banner
            if (ref.watch(e2eeProvider))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                color: const Color(0xFF0D9488).withOpacity(0.12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Color(0xFF0D9488), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      "End-to-End Encrypted (E2EE) Active",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0D9488),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Message List View
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                reverse: false,
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  return MessageBubble(
                    text: msg.content,
                    isUser: msg.role == 'user',
                    modelUsed: msg.role == 'assistant' ? chatState.activeModel : '',
                  );
                },
              ),
            ),

            // Loading / Typing Indicator
            if (chatState.isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'JARVIS is thinking...',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Suggestions / Quick chips list
            if (chatState.messages.length <= 1)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final sug = _suggestions[index];
                    return GestureDetector(
                      onTap: () {
                        chatNotifier.sendMessage(sug);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Center(
                          child: Text(
                            sug,
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0E14),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Microphone shortcut to voice session
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: Colors.grey, size: 24),
                    onPressed: () => context.push('/voice'),
                  ),
                  
                  // Text Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 15),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            chatNotifier.sendMessage(val);
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Send Button
                  GestureDetector(
                    onTap: () {
                      if (_textController.text.trim().isNotEmpty) {
                        chatNotifier.sendMessage(_textController.text);
                        _textController.clear();
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
