import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/custom_bottom_bar.dart';

class E2eeNotifier extends StateNotifier<bool> {
  E2eeNotifier() : super(false) {
    _loadE2ee();
  }

  Future<void> _loadE2ee() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('e2ee_enabled') ?? false;
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('e2ee_enabled', enabled);
  }
}

final e2eeProvider = StateNotifierProvider<E2eeNotifier, bool>((ref) {
  return E2eeNotifier();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _openaiController = TextEditingController();
  final _geminiController = TextEditingController();
  bool _isSaving = false;
  String _message = '';
  bool _openaiConfigured = false;
  bool _geminiConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadKeysStatus();
  }

  Future<void> _loadKeysStatus() async {
    final apiService = ref.read(apiServiceProvider);
    final status = await apiService.getCustomApiKeysStatus();
    setState(() {
      _openaiConfigured = status['openai_key_configured'] ?? false;
      _geminiConfigured = status['gemini_key_configured'] ?? false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _message = '';
    });

    final apiService = ref.read(apiServiceProvider);
    final success = await apiService.saveCustomApiKeys(
      _openaiController.text.trim(),
      _geminiController.text.trim(),
    );

    setState(() {
      _isSaving = false;
      if (success) {
        _message = 'Settings updated successfully!';
        _openaiController.clear();
        _geminiController.clear();
        _loadKeysStatus();
      } else {
        _message = 'Failed to update keys. Check connection.';
      }
    });
  }

  @override
  void dispose() {
    _openaiController.dispose();
    _geminiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e2eeEnabled = ref.watch(e2eeProvider);
    final e2eeNotifier = ref.read(e2eeProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Settings",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: End-to-End Encryption
                    Text(
                      "Security",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131121).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "End-to-End Encryption",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Encrypts chat history on your device before storing/transmitting.",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: e2eeEnabled,
                            activeColor: const Color(0xFF8B5CF6),
                            onChanged: (val) {
                              e2eeNotifier.toggle(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section: Custom Keys
                    Text(
                      "Custom API Keys (Stored locally in database)",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131121).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // OpenAI Key Input
                          Text(
                            "OpenAI API Key",
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _openaiController,
                            obscureText: true,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: _openaiConfigured ? "•••••••••••••••• (Configured)" : "Enter custom OpenAI API key",
                              hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 14),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Gemini Key Input
                          Text(
                            "Gemini API Key",
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _geminiController,
                            obscureText: true,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: _geminiConfigured ? "•••••••••••••••• (Configured)" : "Enter custom Gemini API key",
                              hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 14),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                              ),
                            ),
                          ),

                          if (_message.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                _message,
                                style: GoogleFonts.outfit(
                                  color: _message.contains('successfully') ? Colors.green : Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Save Button
                          GestureDetector(
                            onTap: _isSaving ? null : _saveSettings,
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text(
                                        "Save Configurations",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const CustomBottomBar(activeRoute: '/login'),
          ],
        ),
      ),
    );
  }
}
