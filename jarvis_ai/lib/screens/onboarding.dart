import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07050F),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(_controller.value * 2 * math.pi),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              
              // Text Content at the bottom left
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Text(
                  "Your smart\nassistant is ready\nto help",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Bottom Actions: Indicators + Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page Indicator (pill, dot, dot)
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),

                    // Get Started Button
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6), // Purple
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          "Get Started",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double phase;
  WavePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw background base color
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF07050F));

    // Glow at the top left/center
    final glowPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.25), 180, glowPaint);

    // Glow at the center right
    final glowPaint2 = Paint()
      ..color = const Color(0xFFD946EF).withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.5), 160, glowPaint2);

    // Bottom flowing purple waves
    // Path 1 (Back wave, lighter purple)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.cubicTo(
      size.width * 0.3, size.height * 0.35 + math.sin(phase) * 35,
      size.width * 0.75, size.height * 0.55 - math.cos(phase) * 35,
      size.width, size.height * 0.42,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF6366F1).withOpacity(0.2),
        const Color(0xFF8B5CF6).withOpacity(0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.65));
    canvas.drawPath(path1, paint);

    // Path 2 (Middle wave, vibrant violet)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.52);
    path2.cubicTo(
      size.width * 0.35, size.height * 0.58 + math.cos(phase + 1) * 25,
      size.width * 0.65, size.height * 0.42 + math.sin(phase + 1) * 25,
      size.width, size.height * 0.50,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF8B5CF6).withOpacity(0.25),
        const Color(0xFFD946EF).withOpacity(0.08),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.58));
    canvas.drawPath(path2, paint);

    // Path 3 (Front wave, deep dark purple)
    final path3 = Path();
    path3.moveTo(0, size.height * 0.62);
    path3.cubicTo(
      size.width * 0.25, size.height * 0.52 + math.sin(phase + 2) * 20,
      size.width * 0.70, size.height * 0.68 + math.cos(phase + 2) * 20,
      size.width, size.height * 0.58,
    );
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF1E1B4B).withOpacity(0.9),
        const Color(0xFF0F0B26).withOpacity(0.95),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => oldDelegate.phase != phase;
}
