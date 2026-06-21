import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ============================================================
// 1. PARTICLE FIELD - Floating glowing dots in background
// ============================================================
class ParticleField extends StatefulWidget {
  final Widget child;
  final int particleCount;
  const ParticleField({super.key, required this.child, this.particleCount = 40});

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    _particles = List.generate(
        widget.particleCount, (_) => _Particle.random(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _ParticlePainter(_particles, _controller.value),
            child: const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x, y, size, speed, opacity;
  Color color;

  _Particle(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity,
      required this.color});

  static _Particle random(math.Random rnd) {
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFD946EF),
      const Color(0xFF10A37F),
    ];
    return _Particle(
      x: rnd.nextDouble(),
      y: rnd.nextDouble(),
      size: rnd.nextDouble() * 3 + 1,
      speed: rnd.nextDouble() * 0.008 + 0.002,
      opacity: rnd.nextDouble() * 0.5 + 0.1,
      color: colors[rnd.nextInt(colors.length)],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y - p.speed * t * 10) % 1.0;
      final flickerOpacity =
          p.opacity * (0.7 + 0.3 * math.sin(t * 2 * math.pi * 3 + p.x * 10));
      final paint = Paint()
        ..color = p.color.withOpacity(flickerOpacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
          Offset(p.x * size.width, currentY * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ============================================================
// 2. AURORA BACKGROUND - Shifting neon aurora
// ============================================================
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xFF07050F))),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _AuroraPainter(_ctrl.value),
            child: const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;

    _drawBlob(canvas, size,
        cx: 0.2 + 0.1 * math.sin(angle * 0.7),
        cy: 0.3 + 0.1 * math.cos(angle * 0.5),
        radius: 0.45,
        color: const Color(0xFF8B5CF6).withOpacity(0.07));

    _drawBlob(canvas, size,
        cx: 0.75 + 0.1 * math.cos(angle * 0.6),
        cy: 0.15 + 0.08 * math.sin(angle * 0.4),
        radius: 0.4,
        color: const Color(0xFF06B6D4).withOpacity(0.06));

    _drawBlob(canvas, size,
        cx: 0.5 + 0.12 * math.sin(angle * 0.9),
        cy: 0.8 + 0.06 * math.cos(angle),
        radius: 0.5,
        color: const Color(0xFFD946EF).withOpacity(0.05));
  }

  void _drawBlob(Canvas canvas, Size size,
      {required double cx,
      required double cy,
      required double radius,
      required Color color}) {
    final center = Offset(cx * size.width, cy * size.height);
    final r = radius * size.width;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => true;
}

// ============================================================
// 3. GLOWING BORDER - Animated gradient glow around widgets
// ============================================================
class GlowBorder extends StatefulWidget {
  final Widget child;
  final bool active;
  final double borderRadius;
  final List<Color> colors;
  const GlowBorder({
    super.key,
    required this.child,
    this.active = true,
    this.borderRadius = 20,
    this.colors = const [
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFFD946EF),
      Color(0xFF8B5CF6),
    ],
  });

  @override
  State<GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<GlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => CustomPaint(
        painter: _GlowBorderPainter(
          animValue: _ctrl.value,
          colors: widget.colors,
          borderRadius: widget.borderRadius,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _GlowBorderPainter extends CustomPainter {
  final double animValue;
  final List<Color> colors;
  final double borderRadius;

  _GlowBorderPainter(
      {required this.animValue,
      required this.colors,
      required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final gradient = SweepGradient(
      colors: colors,
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: GradientRotation(animValue * math.pi * 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(_GlowBorderPainter old) => true;
}

// ============================================================
// 4. SHIMMER TEXT - Text with moving shimmer highlight
// ============================================================
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;

  const ShimmerText(
    this.text, {
    super.key,
    this.style,
    this.colors = const [
      Color(0xFF8B5CF6),
      Color(0xFFE879F9),
      Colors.white,
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
    ],
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          colors: widget.colors,
          begin: Alignment(-1.5 + _ctrl.value * 4, 0),
          end: Alignment(-0.5 + _ctrl.value * 4, 0),
        ).createShader(bounds),
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}

// ============================================================
// 5. HOLOGRAPHIC CARD - Glass card with depth holographic sheen
// ============================================================
class HolographicCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  const HolographicCard(
      {super.key, required this.child, this.borderRadius = 20});

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: Colors.white.withOpacity(0.04),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HoloPainter(_ctrl.value,
                        borderRadius: widget.borderRadius),
                  ),
                ),
                child!,
              ],
            ),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}

class _HoloPainter extends CustomPainter {
  final double t;
  final double borderRadius;
  _HoloPainter(this.t, {this.borderRadius = 20});

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;
    final shineX = 0.5 + 0.5 * math.cos(angle);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = LinearGradient(
      begin: Alignment(shineX * 2 - 1, -1),
      end: Alignment(shineX * 2 - 1 + 0.5, 1),
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.04),
        const Color(0xFF8B5CF6).withOpacity(0.04),
        Colors.white.withOpacity(0.05),
        Colors.transparent,
      ],
    ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_HoloPainter old) => true;
}

// ============================================================
// 6. NEON PULSE BUTTON - Button with pulsing neon glow
// ============================================================
class NeonPulseButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final List<Color> gradient;
  final IconData? icon;

  const NeonPulseButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = const [Color(0xFF8B5CF6), Color(0xFFD946EF)],
    this.icon,
  });

  @override
  State<NeonPulseButton> createState() => _NeonPulseButtonState();
}

class _NeonPulseButtonState extends State<NeonPulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 0.8).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: widget.gradient),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(_pulse.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 7. SCAN LINE OVERLAY - Subtle CRT/HUD scan lines
// ============================================================
class ScanlineOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  const ScanlineOverlay(
      {super.key, required this.child, this.opacity = 0.025});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(opacity: opacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  _ScanlinePainter({this.opacity = 0.025});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => false;
}
