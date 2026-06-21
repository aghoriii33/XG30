import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E), // Very dark navy/black
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Top Badge "Personal AI Buddy"
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  "Personal AI Buddy",
                  style: GoogleFonts.outfit(
                    color: Colors.blue[300],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            const Spacer(),

            // Vector Robot Illustration (Cute white robot holding "Hi" bubble)
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow Background
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Robot Head/Body Vector Components
                SizedBox(
                  width: 200,
                  height: 220,
                  child: CustomPaint(
                    painter: RobotPainter(),
                  ),
                ),

                // Speech Bubble "Hi"
                Positioned(
                  top: 30,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8), // Vibrant blue
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Hi",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Lower Section Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Text(
                    "Meet Sundae!",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your own AI assistant",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Ask your questions and receive answers using an artificial intelligence assistant.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Premium Get Started Button
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12151C),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Sliding Capsule Arrow Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.double_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 48), // offset for the circle
                                child: Text(
                                  "Get started",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paints for body, face, details
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final blueDetailPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final screenPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    // 1. Draw Legs / Hover Base
    final hoverPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.85)
      ..lineTo(size.width * 0.6, size.height * 0.85)
      ..lineTo(size.width * 0.55, size.height * 0.95)
      ..lineTo(size.width * 0.45, size.height * 0.95)
      ..close();
    canvas.drawPath(hoverPath, blueDetailPaint);

    final hoverGlow = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.98),
        width: 40,
        height: 6,
      ),
      hoverGlow,
    );

    // 2. Draw Torso / Body
    final torsoRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.65),
      width: 76,
      height: 70,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(16)),
      bodyPaint,
    );

    // Torso screen/belly details
    final bellyRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.66),
      width: 50,
      height: 40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bellyRect, const Radius.circular(8)),
      screenPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.66),
          width: 40,
          height: 30,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.blue.withOpacity(0.1),
    );

    // 3. Draw Arms
    // Left Arm
    final leftArmPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.58)
      ..cubicTo(
        size.width * 0.22, size.height * 0.58,
        size.width * 0.22, size.height * 0.76,
        size.width * 0.3, size.height * 0.76,
      );
    canvas.drawPath(
      leftArmPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(size.width * 0.23, size.height * 0.66), 8, blueDetailPaint);

    // Right Arm (Waving up to bubble)
    final rightArmPath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.58)
      ..cubicTo(
        size.width * 0.78, size.height * 0.52,
        size.width * 0.82, size.height * 0.44,
        size.width * 0.82, size.height * 0.38,
      );
    canvas.drawPath(
      rightArmPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.36), 8, blueDetailPaint);

    // 4. Draw Neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.49),
        width: 22,
        height: 12,
      ),
      blueDetailPaint,
    );

    // 5. Draw Head
    final headRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.39),
      width: 90,
      height: 60,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(22)),
      bodyPaint,
    );

    // Head Face Screen
    final faceRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.39),
      width: 72,
      height: 44,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, const Radius.circular(16)),
      screenPaint,
    );

    // Eyes (Happy blinking curve eyes)
    final eyePaint = Paint()
      ..color = Colors.blue[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Left eye curve
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.38),
        width: 14,
        height: 10,
      ),
      math.pi,
      math.pi,
      false,
      eyePaint,
    );

    // Right eye curve
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.58, size.height * 0.38),
        width: 14,
        height: 10,
      ),
      math.pi,
      math.pi,
      false,
      eyePaint,
    );

    // Cute blush details
    final blushPaint = Paint()..color = Colors.pink.withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.43), 4, blushPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.43), 4, blushPaint);

    // 6. Antenna
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.29),
      Offset(size.width * 0.5, size.height * 0.23),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.20), 8, blueDetailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
