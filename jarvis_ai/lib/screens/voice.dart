import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/voice_service.dart';
import '../widgets/ai_orb.dart';
import '../widgets/voice_wave.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    // Auto-start voice listening when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceServiceProvider.notifier).startVoiceSession();
    });
  }

  @override
  void deactivate() {
    // Auto-stop when exiting screen
    ref.read(voiceServiceProvider.notifier).stopVoiceSession();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceServiceProvider);
    final voiceNotifier = ref.read(voiceServiceProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Top Bar: Back/Menu + Title + Audio Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    "Talking to Sundae",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _speakerOn = !_speakerOn;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Listening status
            Text(
              voiceState.status,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 48),

            // Large Central Glowing AI Orb
            Center(
              child: AiOrb(
                size: 240,
                isActive: voiceState.isListening || voiceState.isSpeaking,
                isSpeaking: voiceState.isSpeaking,
              ),
            ),

            const Spacer(),

            // Speech Transcripts Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  // User's speech text (dimmer)
                  if (voiceState.userText.isNotEmpty)
                    Text(
                      voiceState.userText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Bot's response text (brighter / active)
                  if (voiceState.botText.isNotEmpty)
                    AnimatedOpacity(
                      opacity: voiceState.isSpeaking ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        voiceState.botText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Voice Actions Buttons Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mute Microphone button
                  IconButton(
                    icon: Icon(
                      voiceState.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 28,
                    ),
                    onPressed: () {
                      voiceNotifier.toggleListening();
                    },
                  ),

                  // Middle pulsing wave / speaking indicator button
                  GestureDetector(
                    onTap: () {
                      voiceNotifier.toggleListening();
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.35),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: VoiceWave(
                          isAnimating: voiceState.isListening || voiceState.isSpeaking,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Close / Exit button
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 28,
                    ),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Bar tabs indicator (Home, Wallet, AI active, Settings)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_outlined, color: Colors.grey, size: 20),
                    onPressed: () => context.go('/home'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome_rounded, color: Colors.blueAccent, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.grey, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
