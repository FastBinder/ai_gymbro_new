// lib/widgets/adaptive_text.dart

import 'package:flutter/material.dart';

/// Адаптивный текст, который автоматически уменьшается если не помещается
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double minFontSize;
  final double maxFontSize;

  const AdaptiveText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
        this.maxLines = 1,
        this.minFontSize = 8,
        this.maxFontSize = 14,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Начинаем с максимального размера шрифта
        double fontSize = style?.fontSize ?? maxFontSize;
        TextStyle effectiveStyle = (style ?? const TextStyle()).copyWith(
          fontSize: fontSize,
        );

        // Проверяем, помещается ли текст
        while (fontSize > minFontSize) {
          final textPainter = TextPainter(
            text: TextSpan(text: text, style: effectiveStyle),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          if (!textPainter.didExceedMaxLines &&
              textPainter.width <= constraints.maxWidth) {
            break;
          }

          fontSize -= 0.5;
          effectiveStyle = effectiveStyle.copyWith(fontSize: fontSize);
        }

        return Text(
          text,
          style: effectiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// Кнопка с адаптивным текстом
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AdaptiveButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: AdaptiveText(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                maxFontSize: 16,
                minFontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}