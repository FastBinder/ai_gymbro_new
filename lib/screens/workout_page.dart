// lib/screens/workout_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_plan.dart';
import '../widgets/add_set_dialog.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/active_workout_service.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/optimized_timer.dart';
import '../widgets/optimized_finish_button.dart';
import '../widgets/optimized_buttons.dart';
import 'workout_details_page.dart';
import 'workout_plans_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with TickerProviderStateMixin {
  // Database service
  final DatabaseService _db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    final workoutService = context.watch<ActiveWorkoutService>();
    return workoutService.isWorkoutActive ? _buildActiveWorkout() : _buildWorkoutList();
  }

  Widget _buildWorkoutList() {
    final loc = context.watch<LocalizationService>();
    final workoutService = context.watch<ActiveWorkoutService>();

    // Если тренировка активна, показываем активную тренировку
    if (workoutService.isWorkoutActive) {
      return _buildActiveWorkout();
    }

    // Иначе показываем экран начала тренировки
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryRed.withOpacity(0.1),
                  AppColors.darkRed.withOpacity(0.05),
                ],
              ),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 100,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            loc.get('ready_to_train'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.get('start_workout_motivation'),
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildStartWorkoutButton(loc),
        ],
      ),
    );
  }

  Widget _buildStartWorkoutButton(LocalizationService loc) {
    return OptimizedGradientButton(
      text: loc.get('start_workout'),
      icon: Icons.play_arrow,
      onPressed: _showWorkoutTypeSelection,
      width: loc.currentLanguage == 'ru' ? 240 : 200,
      height: 64,
    );
  }

  void _showWorkoutTypeSelection() {
    final loc = context.read<LocalizationService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              loc.currentLanguage == 'ru' ? 'Выберите тип тренировки' : 'Choose workout type',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Empty workout option
            GymCard(
              onTap: () {
                Navigator.pop(context);
                _startWorkout();
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primaryRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.currentLanguage == 'ru' ? 'Пустая тренировка' : 'Empty workout',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.currentLanguage == 'ru'
                              ? 'Добавляйте упражнения по ходу'
                              : 'Add exercises as you go',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Plan workout option
            GymCard(
              onTap: () async {
                Navigator.pop(context);
                _showPlanSelection();
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_note,
                      color: AppColors.primaryRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.currentLanguage == 'ru' ? 'План тренировки' : 'Workout plan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.currentLanguage == 'ru'
                              ? 'Выберите готовый план'
                              : 'Choose from your plans',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPlanSelection() async {
    final plans = await _db.getAllWorkoutPlans();
    final loc = context.read<LocalizationService>();

    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.currentLanguage == 'ru'
                ? 'У вас нет сохраненных планов'
                : 'You have no saved plans',
          ),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: loc.currentLanguage == 'ru' ? 'Создать' : 'Create',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutPlansPage(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_note,
                    color: AppColors.primaryRed,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loc.currentLanguage == 'ru' ? 'Выберите план' : 'Select a plan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GymCard(
                      onTap: () {
                        Navigator.pop(context);
                        _startWorkoutFromPlan(plan);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (plan.timesUsed > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${plan.timesUsed}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${plan.exercises.length} ${loc.currentLanguage == 'ru' ? 'упр.' : 'ex.'}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.format_list_numbered,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${plan.totalSets} ${loc.currentLanguage == 'ru' ? 'подх.' : 'sets'}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '~${plan.estimatedDuration} ${loc.currentLanguage == 'ru' ? 'мин' : 'min'}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startWorkoutFromPlan(WorkoutPlan plan) {
    final workoutService = context.read<ActiveWorkoutService>();
    final loc = context.read<LocalizationService>();

    // Start workout
    workoutService.startWorkout();

    // Add exercises from plan
    for (var plannedExercise in plan.exercises) {
      workoutService.addExercise(plannedExercise.exercise);
    }

    // Mark plan as used
    _db.markPlanAsUsed(plan.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.currentLanguage == 'ru'
              ? 'Тренировка начата по плану "${plan.name}"'
              : 'Workout started from plan "${plan.name}"',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildActiveWorkout() {
    final loc = context.watch<LocalizationService>();
    final workoutService = context.watch<ActiveWorkoutService>();

    return Column(
      children: [
        // Используем оптимизированную секцию таймеров
        OptimizedTimersSection(
          workoutStartTime: workoutService.workoutStartTime!,
          restStartTime: workoutService.restStartTime,
          setStartTime: workoutService.setStartTime,
          isRestTimerActive: workoutService.isRestTimerActive,
          isSetTimerActive: workoutService.isSetTimerActive,
          localize: (key) => loc.get(key),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...workoutService.currentExercises.asMap().entries.map((entry) =>
                  _buildExerciseCard(entry.key, entry.value)
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryRed,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MaterialButton(
                  onPressed: _showExerciseSelection,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: AppColors.primaryRed),
                      const SizedBox(width: 8),
                      Text(
                        loc.get('add_exercise'),
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Используем оптимизированную кнопку завершения
        OptimizedFinishButton(
          onFinish: _finishWorkout,
          idleText: loc.get('finish_workout'),
          holdText: loc.get('hold_to_finish') ?? 'HOLD TO FINISH',
        ),
      ],
    );
  }

  Widget _buildExerciseCard(int index, WorkoutExercise workoutExercise) {
    final loc = context.watch<LocalizationService>();
    final workoutService = context.watch<ActiveWorkoutService>();
    final isActive = workoutService.activeExerciseIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
            AppColors.primaryRed.withOpacity(0.2),
            AppColors.darkRed.withOpacity(0.1),
          ]
              : [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryRed : AppColors.border,
          width: 2,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutExercise.exercise.getLocalizedName(loc.currentLanguage).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMuscleGroupsDisplay(workoutExercise.exercise),
                    ],
                  ),
                ),
                if (isActive && workoutService.isSetTimerActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      loc.get('active'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
            if (workoutExercise.sets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: workoutExercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${setIndex + 1}',
                              style: const TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.currentLanguage == 'ru'
                                  ? '${set.weight} кг × ${set.reps} повт'
                                  : '${set.weight} kg × ${set.reps} reps',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(set.weight * set.reps).toStringAsFixed(0)} ${loc.currentLanguage == 'ru' ? 'кг' : 'kg'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Action buttons - используем оптимизированные кнопки
            Row(
              children: [
                Expanded(
                  child: OptimizedGradientButton(
                    text: loc.get('start_set'),
                    icon: Icons.play_arrow,
                    onPressed: isActive && workoutService.isSetTimerActive
                        ? () {} // disabled
                        : () => _startSet(index),
                    colors: isActive && workoutService.isSetTimerActive
                        ? [AppColors.textMuted, AppColors.textMuted.withOpacity(0.8)]
                        : [AppColors.success, const Color(0xFF059669)],
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OptimizedGradientButton(
                    text: loc.get('complete'),
                    icon: Icons.check,
                    onPressed: isActive && workoutService.isSetTimerActive
                        ? () => _completeSet(index, workoutExercise)
                        : () {}, // disabled
                    colors: isActive && workoutService.isSetTimerActive
                        ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                        : [AppColors.textMuted, AppColors.textMuted.withOpacity(0.8)],
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupsDisplay(Exercise exercise) {
    final loc = context.watch<LocalizationService>();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Основная мышца
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                size: 14,
                color: AppColors.primaryRed,
              ),
              const SizedBox(width: 4),
              Text(
                loc.get(exercise.primaryMuscle.localizationKey),
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Побочные мышцы
        ...exercise.secondaryMuscles.map((muscle) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            loc.get(muscle.localizationKey),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        )),
      ],
    );
  }

  void _startWorkout() {
    context.read<ActiveWorkoutService>().startWorkout();
  }

  void _startSet(int exerciseIndex) {
    context.read<ActiveWorkoutService>().startSet(exerciseIndex);
  }

  void _completeSet(int exerciseIndex, WorkoutExercise workoutExercise) {
    // Get last set data if exists
    final lastSet = workoutExercise.sets.isNotEmpty
        ? workoutExercise.sets.last
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteSetDialog(
        lastWeight: lastSet?.weight,
        lastReps: lastSet?.reps,
        onComplete: (weight, reps) {
          context.read<ActiveWorkoutService>().completeSet(exerciseIndex, weight, reps);
        },
      ),
    );
  }

  void _showExerciseSelection() async {
    final exercises = await _db.getAllExercises();

    showDialog(
      context: context,
      builder: (context) => _ExerciseSelectionDialog(
        exercises: exercises,
        onSelect: (exercise) {
          context.read<ActiveWorkoutService>().addExercise(exercise);
        },
      ),
    );
  }

  void _finishWorkout() async {
    final loc = context.read<LocalizationService>();
    final workoutService = context.read<ActiveWorkoutService>();

    if (workoutService.currentExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('add_at_least_one_exercise')),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final workout = workoutService.createWorkout();

    try {
      // Save to database
      await _db.createWorkout(workout);

      // Clear workout state
      workoutService.finishWorkout();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('workout_saved')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving workout: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  // Вспомогательные методы для _ExerciseSelectionDialog
  IconData _getCategoryIcon(MuscleCategory category) {
    switch (category) {
      case MuscleCategory.chest:
        return Icons.airline_seat_flat;
      case MuscleCategory.back:
        return Icons.accessibility_new;
      case MuscleCategory.shoulders:
        return Icons.accessibility;
      case MuscleCategory.biceps:
      case MuscleCategory.triceps:
        return Icons.fitness_center;
      case MuscleCategory.legs:
        return Icons.directions_run;
    }
  }
}

// CompleteSetDialog остается без изменений
class CompleteSetDialog extends StatefulWidget {
  final double? lastWeight;
  final int? lastReps;
  final Function(double weight, int reps) onComplete;

  const CompleteSetDialog({
    Key? key,
    this.lastWeight,
    this.lastReps,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CompleteSetDialog> createState() => _CompleteSetDialogState();
}

class _CompleteSetDialogState extends State<CompleteSetDialog> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.lastWeight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.lastReps?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.get('complete_set'),
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.lastWeight != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryRed.withOpacity(0.2),
                          AppColors.darkRed.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryRed,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        widget.onComplete(widget.lastWeight!, widget.lastReps!);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.refresh,
                              color: AppColors.primaryRed,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.get('same_as_last_set'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.currentLanguage == 'ru'
                                  ? '${widget.lastWeight} кг × ${widget.lastReps} повт'
                                  : '${widget.lastWeight} kg × ${widget.lastReps} reps',
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          loc.get('or_enter_manually'),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                GymTextField(
                  controller: _weightController,
                  hintText: loc.get('weight_kg'),
                  prefixIcon: Icons.fitness_center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                GymTextField(
                  controller: _repsController,
                  hintText: loc.get('reps'),
                  prefixIcon: Icons.repeat,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OptimizedOutlineButton(
                        text: loc.get('cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OptimizedGradientButton(
                        text: loc.get('save'),
                        onPressed: () {
                          final weight = double.tryParse(_weightController.text) ?? 0;
                          final reps = int.tryParse(_repsController.text) ?? 0;

                          if (weight > 0 && reps > 0) {
                            widget.onComplete(weight, reps);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}

// Exercise Selection Dialog остается прежним
class _ExerciseSelectionDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final Function(Exercise) onSelect;

  const _ExerciseSelectionDialog({
    Key? key,
    required this.exercises,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<_ExerciseSelectionDialog> createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<_ExerciseSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MuscleCategory? _selectedCategoryFilter;

  List<Exercise> get _filteredExercises {
    return widget.exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == null ||
          exercise.involvesCategory(_selectedCategoryFilter!);
      return matchesSearch && matchesCategory;
    }).toList();
  }

  IconData _getCategoryIcon(MuscleCategory category) {
    switch (category) {
      case MuscleCategory.chest:
        return Icons.airline_seat_flat;
      case MuscleCategory.back:
        return Icons.accessibility_new;
      case MuscleCategory.shoulders:
        return Icons.accessibility;
      case MuscleCategory.biceps:
      case MuscleCategory.triceps:
        return Icons.fitness_center;
      case MuscleCategory.legs:
        return Icons.directions_run;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.1),
                    AppColors.darkRed.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: AppColors.primaryRed,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            loc.get('select_exercise'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.get('search_exercises'),
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Muscle Category Filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: MuscleCategory.values.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // All muscles chip
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(loc.get('all')),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryFilter = null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primaryRed.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryRed,
                        labelStyle: TextStyle(
                          color: _selectedCategoryFilter == null
                              ? AppColors.primaryRed
                              : AppColors.textSecondary,
                          fontWeight: _selectedCategoryFilter == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: _selectedCategoryFilter == null
                              ? AppColors.primaryRed
                              : AppColors.border,
                        ),
                      ),
                    );
                  }

                  final category = MuscleCategory.values[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(loc.get(category.localizationKey)),
                      selected: _selectedCategoryFilter == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryFilter = selected ? category : null;
                        });
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primaryRed.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryRed,
                      labelStyle: TextStyle(
                        color: _selectedCategoryFilter == category
                            ? AppColors.primaryRed
                            : AppColors.textSecondary,
                        fontWeight: _selectedCategoryFilter == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: _selectedCategoryFilter == category
                            ? AppColors.primaryRed
                            : AppColors.border,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // Exercise List
            Flexible(
              child: _filteredExercises.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.get('no_exercises_found'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.get('try_different_filters'),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  final isCustom = exercise.id.length > 10;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GymCard(
                      onTap: () {
                        widget.onSelect(exercise);
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCustom
                                    ? AppColors.orange.withOpacity(0.1)
                                    : AppColors.primaryRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCustom
                                    ? Icons.person
                                    : _getCategoryIcon(exercise.primaryCategory),
                                color: isCustom
                                    ? AppColors.orange
                                    : AppColors.primaryRed,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.getLocalizedName(loc.currentLanguage),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLocalizedMuscleDisplay(exercise, loc),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primaryRed,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedMuscleDisplay(Exercise exercise, LocalizationService loc) {
    final primary = loc.get(exercise.primaryMuscle.localizationKey);
    if (exercise.secondaryMuscles.isEmpty) {
      return primary;
    }
    final secondary = exercise.secondaryMuscles.map((m) => loc.get(m.localizationKey)).join(', ');
    return '$primary • $secondary';
  }
}