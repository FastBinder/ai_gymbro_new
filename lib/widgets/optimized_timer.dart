// lib/widgets/optimized_timer.dart

import 'package:flutter/material.dart';
import 'dart:async';

/// Изолированный виджет таймера который обновляет только себя
class OptimizedTimer extends StatefulWidget {
  final DateTime startTime;
  final TextStyle? style;
  final String Function(Duration)? formatter;
  final VoidCallback? onTick;

  const OptimizedTimer({
    Key? key,
    required this.startTime,
    this.style,
    this.formatter,
    this.onTick,
  }) : super(key: key);

  @override
  State<OptimizedTimer> createState() => _OptimizedTimerState();
}

class _OptimizedTimerState extends State<OptimizedTimer> {
  late Timer _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = DateTime.now().difference(widget.startTime);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = DateTime.now().difference(widget.startTime);
        });
        widget.onTick?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _defaultFormatter(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = widget.formatter ?? _defaultFormatter;

    return RepaintBoundary(
      child: Text(
        formatter(_duration),
        style: widget.style,
      ),
    );
  }
}

/// Виджет с анимированным фоном для активного таймера
class AnimatedTimerContainer extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color activeColor;
  final Duration animationDuration;

  const AnimatedTimerContainer({
    Key? key,
    required this.child,
    required this.isActive,
    this.activeColor = const Color(0xFFDC2626),
    this.animationDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<AnimatedTimerContainer> createState() => _AnimatedTimerContainerState();
}

class _AnimatedTimerContainerState extends State<AnimatedTimerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTimerContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? widget.activeColor.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Transform.scale(
              scale: widget.isActive ? _pulseAnimation.value : 1.0,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Оптимизированная секция таймеров
class OptimizedTimersSection extends StatelessWidget {
  final DateTime workoutStartTime;
  final DateTime? restStartTime;
  final DateTime? setStartTime;
  final bool isRestTimerActive;
  final bool isSetTimerActive;
  final String Function(String) localize;

  const OptimizedTimersSection({
    Key? key,
    required this.workoutStartTime,
    this.restStartTime,
    this.setStartTime,
    required this.isRestTimerActive,
    required this.isSetTimerActive,
    required this.localize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF1A1A1A).withOpacity(0),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Основной таймер тренировки
          _buildMainTimer(context),
          const SizedBox(height: 16),
          // Таймеры отдыха и подхода
          Row(
            children: [
              Expanded(
                child: _buildSubTimer(
                  context: context,
                  title: localize('rest'),
                  startTime: restStartTime,
                  isActive: isRestTimerActive,
                  icon: Icons.pause_circle_filled,
                  color: const Color(0xFFF97316), // warning color
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSubTimer(
                  context: context,
                  title: localize('set'),
                  startTime: setStartTime,
                  isActive: isSetTimerActive,
                  icon: Icons.play_circle_filled,
                  color: const Color(0xFF10B981), // success color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainTimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDC2626).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localize('workout_time'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              OptimizedTimer(
                startTime: workoutStartTime,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          AnimatedTimerContainer(
            isActive: true,
            child: const Icon(
              Icons.timer,
              color: Color(0xFFDC2626),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTimer({
    required BuildContext context,
    required String title,
    required DateTime? startTime,
    required bool isActive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : const Color(0xFF333333),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? color : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? color : const Color(0xFF6B7280),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isActive && startTime != null)
            OptimizedTimer(
              startTime: startTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else
            const Text(
              '00:00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }
}