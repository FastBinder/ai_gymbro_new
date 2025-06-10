// lib/widgets/optimized_finish_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Оптимизированная кнопка завершения тренировки с hold-to-confirm
class OptimizedFinishButton extends StatefulWidget {
  final VoidCallback onFinish;
  final String idleText;
  final String holdText;
  final Duration holdDuration;

  const OptimizedFinishButton({
    Key? key,
    required this.onFinish,
    required this.idleText,
    required this.holdText,
    this.holdDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<OptimizedFinishButton> createState() => _OptimizedFinishButtonState();
}

class _OptimizedFinishButtonState extends State<OptimizedFinishButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.holdDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _colorAnimation = ColorTween(
      begin: const Color(0xFFF97316), // warning
      end: const Color(0xFFDC2626), // primary red
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onFinish();
        _reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    if (mounted) {
      setState(() {
        _isHolding = false;
      });
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() {
            _isHolding = true;
          });
          _controller.forward();
        },
        onTapUp: (_) => _reset(),
        onTapCancel: _reset,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: CustomPaint(
                  painter: _ProgressPainter(
                    progress: _progressAnimation.value,
                    progressColor: _colorAnimation.value!,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _colorAnimation.value!.withOpacity(0.2),
                          const Color(0xFFDC2626).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _isHolding
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFDC2626).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _isHolding ? Icons.timer : Icons.stop,
                              color: Colors.white,
                              size: 24,
                              key: ValueKey(_isHolding),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: Colors.white.withOpacity(_isHolding ? 0.9 : 1.0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            child: Text(
                              _isHolding ? widget.holdText : widget.idleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter для прогресс индикатора
class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _ProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    // Фоновая линия
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(rrect, backgroundPaint);

    // Прогресс линия
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..addRRect(rrect);

      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        final extractPath = metric.extractPath(
          0,
          metric.length * progress,
        );
        canvas.drawPath(extractPath, progressPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

/// Легковесная версия для простых анимаций
class LightweightAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration animationDuration;

  const LightweightAnimatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.animationDuration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<LightweightAnimatedButton> createState() => _LightweightAnimatedButtonState();
}

class _LightweightAnimatedButtonState extends State<LightweightAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}