import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoiceWave extends StatefulWidget {
  final bool isAnimating;
  final double height;
  final Color color;

  const VoiceWave({
    super.key,
    required this.isAnimating,
    this.height = 40.0,
    this.color = Colors.white,
  });

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _barCount = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VoiceWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_barCount, (index) {
            double value = 0.2;
            if (widget.isAnimating) {
              // Offset wave peaks for each bar
              final radian = (_controller.value * 2 * math.pi) + (index * math.pi / 4);
              value = 0.3 + 0.7 * (math.sin(radian).abs());
            }
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: widget.height * value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
