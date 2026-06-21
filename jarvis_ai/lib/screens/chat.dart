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
  final String typingText;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.activeModel = 'ChatGPT-5 Pro',
    this.typingText = '',
  });

  ChatState copyWith({
    List<ChatMessageData>? messages,
    bool? isLoading,
    String? activeModel,
    String? typingText,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      activeModel: activeModel ?? this.activeModel,
      typingText: typingText ?? this.typingText,
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
            content:
                'Hello! I\'m **JARVIS**, your premium AI assistant.\n\nI support 5 powerful AI models:\n* **ChatGPT-5 Pro** — OpenAI\'s most capable model\n* **Claude 3.5 Sonnet** — Anthropic\'s reasoning expert\n* **Gemini 3.1 Pro** — Google\'s multimodal powerhouse\n* **DeepSeek-V3** — Code & reasoning specialist\n* **Grok 2.0** — xAI\'s real-time model\n\nChoose a model above and let\'s get started! 🚀',
          ),
        ]));

  void changeModel(String newModel) {
    state = state.copyWith(activeModel: newModel);
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessageData(
          role: 'assistant',
          content: 'Chat cleared. How can I help you?',
        ),
      ],
      activeModel: state.activeModel,
    );
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
            ? (msg.content.startsWith('E2EE:')
                ? msg.content
                : EncryptionService.encrypt(msg.content, userSecretKey))
            : msg.content;
        encryptedHistory.add(ChatMessageData(role: msg.role, content: encContent));
      }

      final response = await _apiService.sendChatMessage(
        contentToSend,
        state.activeModel,
        encryptedHistory,
      );

      String reply = response['reply'] ?? 'Failed to get response';
      if (e2eeEnabled && reply.startsWith('E2EE:')) {
        reply = EncryptionService.decrypt(reply, userSecretKey);
      }

      final botMsg = ChatMessageData(role: 'assistant', content: reply);
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (e) {
      final botMsg = ChatMessageData(
          role: 'assistant',
          content:
              '⚠️ **Connection Error**\n\nCould not reach JARVIS backend. The local server may be offline.\n\n```\nError: $e\n```\n\nPlease ensure the FastAPI backend is running on port 8000.');
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    }
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatNotifier(apiService, ref);
});

class ChatScreen extends ConsumerStatefulWidget {
  ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _models = [
    {'label': 'ChatGPT-5 Pro', 'icon': Icons.auto_awesome_rounded, 'color': const Color(0xFF10A37F)},
    {'label': 'Claude 3.5 Sonnet (Thinking)', 'icon': Icons.psychology_rounded, 'color': const Color(0xFFD97706)},
    {'label': 'Gemini 3.1 Pro (High)', 'icon': Icons.blur_on_rounded, 'color': const Color(0xFF4285F4)},
    {'label': 'DeepSeek-V3', 'icon': Icons.grain_rounded, 'color': const Color(0xFF06B6D4)},
    {'label': 'Grok 2.0', 'icon': Icons.all_inclusive_rounded, 'color': const Color(0xFFEC4899)},
  ];

  final List<String> _suggestions = [
    '💡 I need UI inspiration...',
    '📊 Analyze my spending...',
    '🧑‍💻 Write a Flutter widget...',
    '🌤️ What\'s the weather like?',
    '🤖 Who are you, JARVIS?',
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);
    final e2eeEnabled = ref.watch(e2eeProvider);

    // Auto scroll on new messages
    ref.listen(chatNotifierProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || prev?.isLoading != next.isLoading) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JARVIS Chat',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              chatState.activeModel,
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          // Clear chat
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
            tooltip: 'Clear Chat',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF131121),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text('Clear Chat',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  content: Text('Remove all messages?',
                      style: GoogleFonts.outfit(color: Colors.white60)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel',
                            style: GoogleFonts.outfit(color: Colors.white54))),
                    ElevatedButton(
                      onPressed: () {
                        chatNotifier.clearChat();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6)),
                      child: Text('Clear',
                          style: GoogleFonts.outfit(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
          // Upgrade to Pro
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded,
                color: Colors.amber, size: 22),
            tooltip: 'Upgrade to Pro',
            onPressed: () async {
              final url = await ref.read(apiServiceProvider).createStripeCheckout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pro checkout: $url',
                        style: GoogleFonts.outfit(fontSize: 12)),
                    backgroundColor: const Color(0xFF8B5CF6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
            // Model Selector Pill Row
            Container(
              height: 56,
              color: const Color(0xFF0C0E14),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: _models.length,
                itemBuilder: (context, index) {
                  final model = _models[index];
                  final label = model['label'] as String;
                  final icon = model['icon'] as IconData;
                  final color = model['color'] as Color;
                  final isSelected = chatState.activeModel == label;
                  return GestureDetector(
                    onTap: () => chatNotifier.changeModel(label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.5)
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon,
                              color: isSelected ? color : Colors.white38,
                              size: 14),
                          const SizedBox(width: 6),
                          Text(
                            label.split('(').first.trim(),
                            style: GoogleFonts.outfit(
                              color: isSelected ? color : Colors.white.withOpacity(0.5),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // E2EE Banner
            if (e2eeEnabled)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                color: const Color(0xFF0D9488).withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded,
                        color: Color(0xFF0D9488), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'End-to-End Encrypted (E2EE) Active',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0D9488),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  return MessageBubble(
                    text: msg.content,
                    isUser: msg.role == 'user',
                    modelUsed:
                        msg.role == 'assistant' ? chatState.activeModel : '',
                  );
                },
              ),
            ),

            // Typing Indicator
            if (chatState.isLoading)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                    const SizedBox(width: 10),
                    Text(
                      'JARVIS is thinking...',
                      style: GoogleFonts.outfit(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Suggestion chips (only on first message)
            if (chatState.messages.length <= 1 && !chatState.isLoading)
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final sug = _suggestions[index];
                    return GestureDetector(
                      onTap: () => chatNotifier.sendMessage(sug),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          sug,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 6),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0E14),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Voice mic shortcut
                  GestureDetector(
                    onTap: () => context.push('/voice'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.mic_none_rounded,
                          color: Colors.white54, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Text field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: e2eeEnabled
                              ? '🔒 Encrypted message...'
                              : 'Ask JARVIS anything...',
                          hintStyle: GoogleFonts.outfit(
                              color: Colors.white30, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: chatState.isLoading ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: chatState.isLoading
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF8B5CF6),
                                  Color(0xFF6D28D9),
                                ],
                              ),
                        color: chatState.isLoading ? Colors.white12 : null,
                        shape: BoxShape.circle,
                        boxShadow: chatState.isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6)
                                      .withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: chatState.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white54),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
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

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 500 + index * 150),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
