// lib/widgets/muscle_body_visualization.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/exercise.dart';
import '../widgets/custom_widgets.dart';

enum TrainingLevel {
  beginner('Новичок', 6, 10),
  intermediate('Средний', 10, 15),
  advanced('Продвинутый', 15, 20);

  final String name;
  final int minSets;
  final int maxSets;

  const TrainingLevel(this.name, this.minSets, this.maxSets);
}

class MuscleBodyVisualization extends StatelessWidget {
  final Map<MuscleGroup, double> muscleStats;
  final TrainingLevel trainingLevel;
  final bool showBack;

  const MuscleBodyVisualization({
    Key? key,
    required this.muscleStats,
    required this.trainingLevel,
    this.showBack = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            showBack ? 'ЗАДНЯЯ ЧАСТЬ' : 'ПЕРЕДНЯЯ ЧАСТЬ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: CustomPaint(
              painter: showBack
                  ? BackMuscleBodyPainter(muscleStats, trainingLevel)
                  : FrontMuscleBodyPainter(muscleStats, trainingLevel),
              child: Container(),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Недостаточно', AppColors.warning.withOpacity(0.5)),
        const SizedBox(width: 20),
        _buildLegendItem('Норма', AppColors.success.withOpacity(0.5)),
        const SizedBox(width: 20),
        _buildLegendItem('Избыток', AppColors.orange.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Painter для передней части тела
class FrontMuscleBodyPainter extends CustomPainter {
  final Map<MuscleGroup, double> muscleStats;
  final TrainingLevel trainingLevel;

  FrontMuscleBodyPainter(this.muscleStats, this.trainingLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.textSecondary;

    // Масштаб и центр
    final centerX = size.width / 2;
    final scale = size.height / 600; // Базовая высота 600

    // Функция для получения цвета на основе выполнения нормы
    Color getMuscleColor(MuscleGroup muscle) {
      final sets = muscleStats[muscle] ?? 0;
      if (sets < trainingLevel.minSets) {
        return AppColors.warning.withOpacity(0.5);
      } else if (sets <= trainingLevel.maxSets) {
        return AppColors.success.withOpacity(0.5);
      } else {
        return AppColors.orange.withOpacity(0.5);
      }
    }

    // Грудь (Chest)
    paint.color = getMuscleColor(MuscleGroup.chest);
    final chestPath = Path()
      ..moveTo(centerX - 60 * scale, 100 * scale)
      ..quadraticBezierTo(centerX - 80 * scale, 120 * scale, centerX - 70 * scale, 150 * scale)
      ..lineTo(centerX - 20 * scale, 160 * scale)
      ..lineTo(centerX, 165 * scale)
      ..lineTo(centerX + 20 * scale, 160 * scale)
      ..lineTo(centerX + 70 * scale, 150 * scale)
      ..quadraticBezierTo(centerX + 80 * scale, 120 * scale, centerX + 60 * scale, 100 * scale)
      ..close();
    canvas.drawPath(chestPath, paint);
    canvas.drawPath(chestPath, outlinePaint);

    // Передние дельты (Front Delts)
    paint.color = getMuscleColor(MuscleGroup.frontDelts);
    // Левая дельта
    final leftDeltPath = Path()
      ..moveTo(centerX - 60 * scale, 100 * scale)
      ..quadraticBezierTo(centerX - 90 * scale, 110 * scale, centerX - 95 * scale, 130 * scale)
      ..lineTo(centerX - 80 * scale, 150 * scale)
      ..lineTo(centerX - 70 * scale, 140 * scale)
      ..close();
    canvas.drawPath(leftDeltPath, paint);
    canvas.drawPath(leftDeltPath, outlinePaint);

    // Правая дельта
    final rightDeltPath = Path()
      ..moveTo(centerX + 60 * scale, 100 * scale)
      ..quadraticBezierTo(centerX + 90 * scale, 110 * scale, centerX + 95 * scale, 130 * scale)
      ..lineTo(centerX + 80 * scale, 150 * scale)
      ..lineTo(centerX + 70 * scale, 140 * scale)
      ..close();
    canvas.drawPath(rightDeltPath, paint);
    canvas.drawPath(rightDeltPath, outlinePaint);

    // Пресс (Abs)
    paint.color = getMuscleColor(MuscleGroup.abs);
    final absPath = Path()
      ..moveTo(centerX - 30 * scale, 165 * scale)
      ..lineTo(centerX - 25 * scale, 250 * scale)
      ..lineTo(centerX - 15 * scale, 280 * scale)
      ..lineTo(centerX, 285 * scale)
      ..lineTo(centerX + 15 * scale, 280 * scale)
      ..lineTo(centerX + 25 * scale, 250 * scale)
      ..lineTo(centerX + 30 * scale, 165 * scale)
      ..close();
    canvas.drawPath(absPath, paint);
    canvas.drawPath(absPath, outlinePaint);

    // Косые мышцы (Obliques)
    paint.color = getMuscleColor(MuscleGroup.obliques);
    // Левые косые
    final leftObliquePath = Path()
      ..moveTo(centerX - 30 * scale, 165 * scale)
      ..lineTo(centerX - 60 * scale, 180 * scale)
      ..lineTo(centerX - 55 * scale, 240 * scale)
      ..lineTo(centerX - 25 * scale, 250 * scale)
      ..close();
    canvas.drawPath(leftObliquePath, paint);
    canvas.drawPath(leftObliquePath, outlinePaint);

    // Правые косые
    final rightObliquePath = Path()
      ..moveTo(centerX + 30 * scale, 165 * scale)
      ..lineTo(centerX + 60 * scale, 180 * scale)
      ..lineTo(centerX + 55 * scale, 240 * scale)
      ..lineTo(centerX + 25 * scale, 250 * scale)
      ..close();
    canvas.drawPath(rightObliquePath, paint);
    canvas.drawPath(rightObliquePath, outlinePaint);

    // Бицепс (Biceps)
    paint.color = getMuscleColor(MuscleGroup.biceps);
    // Левый бицепс
    final leftBicepPath = Path()
      ..moveTo(centerX - 95 * scale, 140 * scale)
      ..lineTo(centerX - 105 * scale, 180 * scale)
      ..lineTo(centerX - 95 * scale, 220 * scale)
      ..lineTo(centerX - 80 * scale, 210 * scale)
      ..lineTo(centerX - 75 * scale, 150 * scale)
      ..close();
    canvas.drawPath(leftBicepPath, paint);
    canvas.drawPath(leftBicepPath, outlinePaint);

    // Правый бицепс
    final rightBicepPath = Path()
      ..moveTo(centerX + 95 * scale, 140 * scale)
      ..lineTo(centerX + 105 * scale, 180 * scale)
      ..lineTo(centerX + 95 * scale, 220 * scale)
      ..lineTo(centerX + 80 * scale, 210 * scale)
      ..lineTo(centerX + 75 * scale, 150 * scale)
      ..close();
    canvas.drawPath(rightBicepPath, paint);
    canvas.drawPath(rightBicepPath, outlinePaint);

    // Предплечья (Forearms)
    paint.color = getMuscleColor(MuscleGroup.forearms);
    // Левое предплечье
    final leftForearmPath = Path()
      ..moveTo(centerX - 95 * scale, 220 * scale)
      ..lineTo(centerX - 90 * scale, 280 * scale)
      ..lineTo(centerX - 80 * scale, 320 * scale)
      ..lineTo(centerX - 70 * scale, 310 * scale)
      ..lineTo(centerX - 75 * scale, 210 * scale)
      ..close();
    canvas.drawPath(leftForearmPath, paint);
    canvas.drawPath(leftForearmPath, outlinePaint);

    // Правое предплечье
    final rightForearmPath = Path()
      ..moveTo(centerX + 95 * scale, 220 * scale)
      ..lineTo(centerX + 90 * scale, 280 * scale)
      ..lineTo(centerX + 80 * scale, 320 * scale)
      ..lineTo(centerX + 70 * scale, 310 * scale)
      ..lineTo(centerX + 75 * scale, 210 * scale)
      ..close();
    canvas.drawPath(rightForearmPath, paint);
    canvas.drawPath(rightForearmPath, outlinePaint);

    // Квадрицепс (Quadriceps)
    paint.color = getMuscleColor(MuscleGroup.quadriceps);
    // Левый квадрицепс
    final leftQuadPath = Path()
      ..moveTo(centerX - 20 * scale, 285 * scale)
      ..lineTo(centerX - 40 * scale, 320 * scale)
      ..lineTo(centerX - 45 * scale, 400 * scale)
      ..lineTo(centerX - 35 * scale, 440 * scale)
      ..lineTo(centerX - 20 * scale, 430 * scale)
      ..lineTo(centerX - 10 * scale, 350 * scale)
      ..close();
    canvas.drawPath(leftQuadPath, paint);
    canvas.drawPath(leftQuadPath, outlinePaint);

    // Правый квадрицепс
    final rightQuadPath = Path()
      ..moveTo(centerX + 20 * scale, 285 * scale)
      ..lineTo(centerX + 40 * scale, 320 * scale)
      ..lineTo(centerX + 45 * scale, 400 * scale)
      ..lineTo(centerX + 35 * scale, 440 * scale)
      ..lineTo(centerX + 20 * scale, 430 * scale)
      ..lineTo(centerX + 10 * scale, 350 * scale)
      ..close();
    canvas.drawPath(rightQuadPath, paint);
    canvas.drawPath(rightQuadPath, outlinePaint);

    // Икры (Calves)
    paint.color = getMuscleColor(MuscleGroup.calves);
    // Левая икра
    final leftCalfPath = Path()
      ..moveTo(centerX - 35 * scale, 440 * scale)
      ..lineTo(centerX - 40 * scale, 480 * scale)
      ..lineTo(centerX - 35 * scale, 540 * scale)
      ..lineTo(centerX - 25 * scale, 550 * scale)
      ..lineTo(centerX - 20 * scale, 540 * scale)
      ..lineTo(centerX - 20 * scale, 450 * scale)
      ..close();
    canvas.drawPath(leftCalfPath, paint);
    canvas.drawPath(leftCalfPath, outlinePaint);

    // Правая икра
    final rightCalfPath = Path()
      ..moveTo(centerX + 35 * scale, 440 * scale)
      ..lineTo(centerX + 40 * scale, 480 * scale)
      ..lineTo(centerX + 35 * scale, 540 * scale)
      ..lineTo(centerX + 25 * scale, 550 * scale)
      ..lineTo(centerX + 20 * scale, 540 * scale)
      ..lineTo(centerX + 20 * scale, 450 * scale)
      ..close();
    canvas.drawPath(rightCalfPath, paint);
    canvas.drawPath(rightCalfPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter для задней части тела
class BackMuscleBodyPainter extends CustomPainter {
  final Map<MuscleGroup, double> muscleStats;
  final TrainingLevel trainingLevel;

  BackMuscleBodyPainter(this.muscleStats, this.trainingLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.textSecondary;

    // Масштаб и центр
    final centerX = size.width / 2;
    final scale = size.height / 600;

    // Функция для получения цвета
    Color getMuscleColor(MuscleGroup muscle) {
      final sets = muscleStats[muscle] ?? 0;
      if (sets < trainingLevel.minSets) {
        return AppColors.warning.withOpacity(0.5);
      } else if (sets <= trainingLevel.maxSets) {
        return AppColors.success.withOpacity(0.5);
      } else {
        return AppColors.orange.withOpacity(0.5);
      }
    }

    // Трапеция (Traps)
    paint.color = getMuscleColor(MuscleGroup.traps);
    final trapsPath = Path()
      ..moveTo(centerX - 40 * scale, 80 * scale)
      ..lineTo(centerX - 60 * scale, 100 * scale)
      ..lineTo(centerX - 50 * scale, 140 * scale)
      ..lineTo(centerX - 20 * scale, 150 * scale)
      ..lineTo(centerX, 155 * scale)
      ..lineTo(centerX + 20 * scale, 150 * scale)
      ..lineTo(centerX + 50 * scale, 140 * scale)
      ..lineTo(centerX + 60 * scale, 100 * scale)
      ..lineTo(centerX + 40 * scale, 80 * scale)
      ..close();
    canvas.drawPath(trapsPath, paint);
    canvas.drawPath(trapsPath, outlinePaint);

    // Задние дельты (Rear Delts)
    paint.color = getMuscleColor(MuscleGroup.rearDelts);
    // Левая задняя дельта
    final leftRearDeltPath = Path()
      ..moveTo(centerX - 60 * scale, 100 * scale)
      ..quadraticBezierTo(centerX - 90 * scale, 110 * scale, centerX - 95 * scale, 130 * scale)
      ..lineTo(centerX - 80 * scale, 150 * scale)
      ..lineTo(centerX - 50 * scale, 140 * scale)
      ..close();
    canvas.drawPath(leftRearDeltPath, paint);
    canvas.drawPath(leftRearDeltPath, outlinePaint);

    // Правая задняя дельта
    final rightRearDeltPath = Path()
      ..moveTo(centerX + 60 * scale, 100 * scale)
      ..quadraticBezierTo(centerX + 90 * scale, 110 * scale, centerX + 95 * scale, 130 * scale)
      ..lineTo(centerX + 80 * scale, 150 * scale)
      ..lineTo(centerX + 50 * scale, 140 * scale)
      ..close();
    canvas.drawPath(rightRearDeltPath, paint);
    canvas.drawPath(rightRearDeltPath, outlinePaint);

    // Широчайшие (Lats)
    paint.color = getMuscleColor(MuscleGroup.lats);
    // Левая широчайшая
    final leftLatPath = Path()
      ..moveTo(centerX - 50 * scale, 150 * scale)
      ..lineTo(centerX - 80 * scale, 160 * scale)
      ..lineTo(centerX - 85 * scale, 220 * scale)
      ..lineTo(centerX - 60 * scale, 240 * scale)
      ..lineTo(centerX - 30 * scale, 230 * scale)
      ..lineTo(centerX - 20 * scale, 180 * scale)
      ..close();
    canvas.drawPath(leftLatPath, paint);
    canvas.drawPath(leftLatPath, outlinePaint);

    // Правая широчайшая
    final rightLatPath = Path()
      ..moveTo(centerX + 50 * scale, 150 * scale)
      ..lineTo(centerX + 80 * scale, 160 * scale)
      ..lineTo(centerX + 85 * scale, 220 * scale)
      ..lineTo(centerX + 60 * scale, 240 * scale)
      ..lineTo(centerX + 30 * scale, 230 * scale)
      ..lineTo(centerX + 20 * scale, 180 * scale)
      ..close();
    canvas.drawPath(rightLatPath, paint);
    canvas.drawPath(rightLatPath, outlinePaint);

    // Средняя часть спины (Middle Back)
    paint.color = getMuscleColor(MuscleGroup.middleBack);
    final middleBackPath = Path()
      ..moveTo(centerX - 20 * scale, 160 * scale)
      ..lineTo(centerX - 30 * scale, 230 * scale)
      ..lineTo(centerX, 240 * scale)
      ..lineTo(centerX + 30 * scale, 230 * scale)
      ..lineTo(centerX + 20 * scale, 160 * scale)
      ..close();
    canvas.drawPath(middleBackPath, paint);
    canvas.drawPath(middleBackPath, outlinePaint);

    // Нижняя часть спины (Lower Back)
    paint.color = getMuscleColor(MuscleGroup.lowerBack);
    final lowerBackPath = Path()
      ..moveTo(centerX - 30 * scale, 230 * scale)
      ..lineTo(centerX - 25 * scale, 280 * scale)
      ..lineTo(centerX, 285 * scale)
      ..lineTo(centerX + 25 * scale, 280 * scale)
      ..lineTo(centerX + 30 * scale, 230 * scale)
      ..close();
    canvas.drawPath(lowerBackPath, paint);
    canvas.drawPath(lowerBackPath, outlinePaint);

    // Трицепс (Triceps)
    paint.color = getMuscleColor(MuscleGroup.triceps);
    // Левый трицепс
    final leftTricepPath = Path()
      ..moveTo(centerX - 75 * scale, 150 * scale)
      ..lineTo(centerX - 85 * scale, 160 * scale)
      ..lineTo(centerX - 95 * scale, 210 * scale)
      ..lineTo(centerX - 85 * scale, 220 * scale)
      ..lineTo(centerX - 75 * scale, 210 * scale)
      ..close();
    canvas.drawPath(leftTricepPath, paint);
    canvas.drawPath(leftTricepPath, outlinePaint);

    // Правый трицепс
    final rightTricepPath = Path()
      ..moveTo(centerX + 75 * scale, 150 * scale)
      ..lineTo(centerX + 85 * scale, 160 * scale)
      ..lineTo(centerX + 95 * scale, 210 * scale)
      ..lineTo(centerX + 85 * scale, 220 * scale)
      ..lineTo(centerX + 75 * scale, 210 * scale)
      ..close();
    canvas.drawPath(rightTricepPath, paint);
    canvas.drawPath(rightTricepPath, outlinePaint);

    // Ягодицы (Glutes)
    paint.color = getMuscleColor(MuscleGroup.glutes);
    // Левая ягодица
    final leftGlutePath = Path()
      ..moveTo(centerX - 15 * scale, 280 * scale)
      ..quadraticBezierTo(centerX - 45 * scale, 300 * scale, centerX - 40 * scale, 340 * scale)
      ..lineTo(centerX - 20 * scale, 350 * scale)
      ..lineTo(centerX - 5 * scale, 340 * scale)
      ..close();
    canvas.drawPath(leftGlutePath, paint);
    canvas.drawPath(leftGlutePath, outlinePaint);

    // Правая ягодица
    final rightGlutePath = Path()
      ..moveTo(centerX + 15 * scale, 280 * scale)
      ..quadraticBezierTo(centerX + 45 * scale, 300 * scale, centerX + 40 * scale, 340 * scale)
      ..lineTo(centerX + 20 * scale, 350 * scale)
      ..lineTo(centerX + 5 * scale, 340 * scale)
      ..close();
    canvas.drawPath(rightGlutePath, paint);
    canvas.drawPath(rightGlutePath, outlinePaint);

    // Бицепс бедра (Hamstrings)
    paint.color = getMuscleColor(MuscleGroup.hamstrings);
    // Левый бицепс бедра
    final leftHamstringPath = Path()
      ..moveTo(centerX - 40 * scale, 340 * scale)
      ..lineTo(centerX - 45 * scale, 420 * scale)
      ..lineTo(centerX - 35 * scale, 440 * scale)
      ..lineTo(centerX - 20 * scale, 430 * scale)
      ..lineTo(centerX - 15 * scale, 350 * scale)
      ..close();
    canvas.drawPath(leftHamstringPath, paint);
    canvas.drawPath(leftHamstringPath, outlinePaint);

    // Правый бицепс бедра
    final rightHamstringPath = Path()
      ..moveTo(centerX + 40 * scale, 340 * scale)
      ..lineTo(centerX + 45 * scale, 420 * scale)
      ..lineTo(centerX + 35 * scale, 440 * scale)
      ..lineTo(centerX + 20 * scale, 430 * scale)
      ..lineTo(centerX + 15 * scale, 350 * scale)
      ..close();
    canvas.drawPath(rightHamstringPath, paint);
    canvas.drawPath(rightHamstringPath, outlinePaint);

    // Икры сзади такие же как спереди
    paint.color = getMuscleColor(MuscleGroup.calves);
    // Левая икра
    final leftCalfPath = Path()
      ..moveTo(centerX - 35 * scale, 440 * scale)
      ..lineTo(centerX - 40 * scale, 480 * scale)
      ..lineTo(centerX - 35 * scale, 540 * scale)
      ..lineTo(centerX - 25 * scale, 550 * scale)
      ..lineTo(centerX - 20 * scale, 540 * scale)
      ..lineTo(centerX - 20 * scale, 450 * scale)
      ..close();
    canvas.drawPath(leftCalfPath, paint);
    canvas.drawPath(leftCalfPath, outlinePaint);

    // Правая икра
    final rightCalfPath = Path()
      ..moveTo(centerX + 35 * scale, 440 * scale)
      ..lineTo(centerX + 40 * scale, 480 * scale)
      ..lineTo(centerX + 35 * scale, 540 * scale)
      ..lineTo(centerX + 25 * scale, 550 * scale)
      ..lineTo(centerX + 20 * scale, 540 * scale)
      ..lineTo(centerX + 20 * scale, 450 * scale)
      ..close();
    canvas.drawPath(rightCalfPath, paint);
    canvas.drawPath(rightCalfPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}