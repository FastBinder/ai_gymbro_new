// lib/widgets/custom_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Цветовая палитра приложения
class AppColors {
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color darkRed = Color(0xFF991B1B);
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF0A0A0A);
  static const Color border = Color(0xFF333333);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFEF4444);
  static const Color orange = Color(0xFFF97316);
}

// Константы для размеров
class AppDimensions {
  static const double buttonHeight = 56.0;
  static const double cardPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double spacing = 8.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  // Breakpoints для адаптивности
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

// Адаптивный текст
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double minFontSize;
  final double? maxFontSize;
  final TextOverflow overflow;

  const AdaptiveText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
        this.maxLines = 1,
        this.minFontSize = 10,
        this.maxFontSize,
        this.overflow = TextOverflow.ellipsis,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final defaultStyle = DefaultTextStyle.of(context).style;
        final effectiveStyle = defaultStyle.merge(style);
        final maxSize = maxFontSize ?? effectiveStyle.fontSize ?? 14;

        double fontSize = maxSize;
        TextStyle currentStyle = effectiveStyle.copyWith(fontSize: fontSize);

        // Проверяем, помещается ли текст
        while (fontSize > minFontSize) {
          final textPainter = TextPainter(
            text: TextSpan(text: text, style: currentStyle),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
          )..layout(maxWidth: constraints.maxWidth);

          if (!textPainter.didExceedMaxLines &&
              textPainter.width <= constraints.maxWidth) {
            break;
          }

          fontSize -= 0.5;
          currentStyle = effectiveStyle.copyWith(fontSize: fontSize);
        }

        return Text(
          text,
          style: currentStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

// Улучшенная основная кнопка с градиентом
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final List<Color>? colors;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool hapticFeedback;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.colors,
    this.width,
    this.height,
    this.isLoading = false,
    this.hapticFeedback = true,
    this.padding,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;
    final effectiveHeight = widget.height ??
        (isSmallScreen ? 48.0 : AppDimensions.buttonHeight);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: effectiveHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.colors ?? [AppColors.primaryRed, AppColors.darkRed],
              ),
              borderRadius: BorderRadius.circular(effectiveHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: (widget.colors?.first ?? AppColors.primaryRed).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(effectiveHeight / 2),
              child: InkWell(
                onTap: widget.isLoading ? null : () {
                  if (widget.hapticFeedback) {
                    HapticFeedback.lightImpact();
                  }
                  widget.onPressed();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(effectiveHeight / 2),
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                        ],
                        Flexible(
                          child: AdaptiveText(
                            widget.text.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Улучшенная кнопка с обводкой
class OutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? borderColor;
  final double? width;
  final bool hapticFeedback;

  const OutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.borderColor,
    this.width,
    this.hapticFeedback = true,
  }) : super(key: key);

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;
    final effectiveHeight = isSmallScreen ? 48.0 : AppDimensions.buttonHeight;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: effectiveHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveHeight / 2),
              border: Border.all(
                color: widget.borderColor ?? AppColors.primaryRed,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(effectiveHeight / 2),
              child: InkWell(
                onTap: () {
                  if (widget.hapticFeedback) {
                    HapticFeedback.lightImpact();
                  }
                  widget.onPressed();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(effectiveHeight / 2),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.borderColor ?? AppColors.primaryRed,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                        ],
                        Flexible(
                          child: AdaptiveText(
                            widget.text.toUpperCase(),
                            style: TextStyle(
                              color: widget.borderColor ?? AppColors.primaryRed,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Адаптивная карточка
class GymCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool isActive;
  final List<Color>? gradientColors;
  final bool hapticFeedback;

  const GymCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.isActive = false,
    this.gradientColors,
    this.hapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;
    final effectivePadding = padding ?? EdgeInsets.all(
      isSmallScreen ? 12 : AppDimensions.cardPadding,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive && gradientColors != null
              ? gradientColors!
              : [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(
          isSmallScreen ? 12 : AppDimensions.borderRadius,
        ),
        border: Border.all(
          color: isActive ? AppColors.primaryRed : AppColors.border,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          isSmallScreen ? 12 : AppDimensions.borderRadius,
        ),
        child: InkWell(
          onTap: onTap == null ? null : () {
            if (hapticFeedback) {
              HapticFeedback.selectionClick();
            }
            onTap!();
          },
          borderRadius: BorderRadius.circular(
            isSmallScreen ? 12 : AppDimensions.borderRadius,
          ),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// Shimmer эффект для загрузки
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerWidget({
    Key? key,
    required this.child,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
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

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Адаптивный контейнер для разных размеров экрана
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveMaxWidth = maxWidth ?? _getMaxWidth(screenWidth);

    return Center(
      child: Container(
        width: screenWidth > effectiveMaxWidth ? effectiveMaxWidth : null,
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(screenWidth),
        ),
        child: child,
      ),
    );
  }

  double _getMaxWidth(double screenWidth) {
    if (screenWidth > AppDimensions.desktopBreakpoint) {
      return AppDimensions.desktopBreakpoint * 0.8;
    } else if (screenWidth > AppDimensions.tabletBreakpoint) {
      return AppDimensions.tabletBreakpoint * 0.9;
    }
    return double.infinity;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < AppDimensions.mobileBreakpoint) {
      return 16;
    } else if (screenWidth < AppDimensions.tabletBreakpoint) {
      return 24;
    }
    return 32;
  }
}

// Остальные виджеты остаются без изменений...
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;

    return GymCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryRed,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AdaptiveText(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              maxLines: 2,
            ),
          ),
          AdaptiveText(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// Остальные виджеты (EmptyState, GymAppBar, GymTextField, CategoryChip)
// тоже можно улучшить аналогичным образом...

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;

    return ResponsiveContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.1),
                    AppColors.darkRed.withOpacity(0.05),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: isSmallScreen ? 60 : 80,
                color: AppColors.primaryRed,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            AdaptiveText(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            AdaptiveText(
              subtitle,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            if (action != null) ...[
              SizedBox(height: isSmallScreen ? 24 : 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class GymTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool obscureText;
  final int? maxLines;

  const GymTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;

    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: isSmallScreen ? 16 : 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.primaryRed)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 12 : 16,
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;

    return Container(
      margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryRed : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryRed : AppColors.border,
                width: 1,
              ),
            ),
            child: AdaptiveText(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}