// lib/widgets/optimized_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Оптимизированная градиентная кнопка
class OptimizedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final List<Color>? colors;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool hapticFeedback;

  const OptimizedGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.colors,
    this.width,
    this.height,
    this.isLoading = false,
    this.hapticFeedback = true,
  }) : super(key: key);

  @override
  State<OptimizedGradientButton> createState() => _OptimizedGradientButtonState();
}

class _OptimizedGradientButtonState extends State<OptimizedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Кэшируем градиент для избежания пересоздания
  late final LinearGradient _gradient;
  late final BoxShadow _shadow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Инициализируем градиент один раз
    _gradient = LinearGradient(
      colors: widget.colors ?? const [Color(0xFFDC2626), Color(0xFF991B1B)],
    );

    _shadow = BoxShadow(
      color: (_gradient.colors.first).withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (!widget.isLoading) {
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = widget.height ?? 56.0;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: effectiveHeight,
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(effectiveHeight / 2),
                boxShadow: [_shadow],
              ),
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(effectiveHeight / 2),
          child: InkWell(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(effectiveHeight / 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ButtonContent(
                text: widget.text,
                icon: widget.icon,
                isLoading: widget.isLoading,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Отдельный виджет для контента кнопки
class _ButtonContent extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isLoading;

  const _ButtonContent({
    required this.text,
    this.icon,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Оптимизированная кнопка с обводкой
class OptimizedOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? borderColor;
  final double? width;

  const OptimizedOutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.borderColor,
    this.width,
  }) : super(key: key);

  @override
  State<OptimizedOutlineButton> createState() => _OptimizedOutlineButtonState();
}

class _OptimizedOutlineButtonState extends State<OptimizedOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.borderColor ?? const Color(0xFFDC2626);

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: widget.width,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ButtonContent(
                    text: widget.text,
                    icon: widget.icon,
                    isLoading: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Легковесная анимированная иконка
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final Duration animationDuration;

  const AnimatedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.25,
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
          animation: _rotationAnimation,
          builder: (context, child) {
            return RotationTransition(
              turns: _rotationAnimation,
              child: child,
            );
          },
          child: Icon(
            widget.icon,
            color: widget.color ?? const Color(0xFFDC2626),
            size: widget.size,
          ),
        ),
      ),
    );
  }
}