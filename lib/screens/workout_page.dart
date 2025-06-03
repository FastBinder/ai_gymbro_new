// lib/screens/workout_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../widgets/add_set_dialog.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/active_workout_service.dart';
import '../widgets/custom_widgets.dart';
import 'workout_details_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with TickerProviderStateMixin {
  // Database service
  final DatabaseService _db = DatabaseService.instance;



  // Timer
  Timer? _timer;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _holdController;
  late Animation<double> _holdAnimation;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Initialize pulse animation for active timer
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Initialize hold animation
    _holdController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _holdAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeInOut,
    ));

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishWorkout();
        _holdController.reset();
        setState(() {
          _isHolding = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }
  Widget _buildTimersSection() {
    final loc = context.watch<LocalizationService>();
    final workoutService = context.watch<ActiveWorkoutService>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main workout timer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryRed.withOpacity(0.3),
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
                      loc.get('workout_time'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(workoutService.workoutDuration),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.timer,
                      color: AppColors.primaryRed,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Rest and Set timers
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: workoutService.isRestTimerActive
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: workoutService.isRestTimerActive
                          ? AppColors.warning
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_circle_filled,
                            size: 20,
                            color: workoutService.isRestTimerActive
                                ? AppColors.warning
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('rest'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: workoutService.isRestTimerActive
                                  ? AppColors.warning
                                  : AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(workoutService.restDuration),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: workoutService.isRestTimerActive
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: workoutService.isSetTimerActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: workoutService.isSetTimerActive
                          ? AppColors.success
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            size: 20,
                            color: workoutService.isSetTimerActive
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('set'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: workoutService.isSetTimerActive
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(workoutService.setDuration),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: workoutService.isSetTimerActive
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


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
            style: TextStyle(
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
    return Container(
      height: 64,
      width: loc.currentLanguage == 'ru' ? 240 : 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.darkRed],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: _startWorkout,
          borderRadius: BorderRadius.circular(32),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      loc.get('start_workout'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildActiveWorkout() {
    final loc = context.watch<LocalizationService>();
    final workoutService = context.watch<ActiveWorkoutService>();

    return Column(
      children: [
        _buildTimersSection(),
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
        _buildFinishButton(),
      ],
    );
  }

  Widget _buildFinishButton() {
    final loc = context.watch<LocalizationService>();

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isHolding = true;
        });
        _holdController.forward();
      },
      onTapUp: (_) {
        setState(() {
          _isHolding = false;
        });
        _holdController.reverse();
      },
      onTapCancel: () {
        setState(() {
          _isHolding = false;
        });
        _holdController.reverse();
      },
      child: AnimatedBuilder(
        animation: _holdAnimation,
        builder: (context, child) {
          return Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Stack(
              children: [
                // Background container
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning.withOpacity(0.3),
                        AppColors.primaryRed.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _isHolding
                          ? AppColors.primaryRed
                          : AppColors.primaryRed.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
                // Animated fill
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AnimatedBuilder(
                    animation: _holdAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: const [
                              AppColors.warning,
                              AppColors.primaryRed,
                            ],
                            stops: [0.0, _holdAnimation.value],
                          ).createShader(rect);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Progress indicator overlay
                if (_isHolding)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: LinearProgressIndicator(
                        value: _holdAnimation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryRed.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                // Content
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isHolding ? Icons.timer : Icons.stop,
                          color: _isHolding
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white,
                          size: 24,
                          key: ValueKey(_isHolding),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: _isHolding
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        child: Text(
                          _isHolding
                              ? loc.get('hold_to_finish') ?? 'HOLD TO FINISH'
                              : loc.get('finish_workout'),
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular progress around button
                if (_isHolding)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        value: _holdAnimation.value,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
                            style: TextStyle(
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
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isActive && workoutService.isSetTimerActive
                          ? LinearGradient(
                        colors: [
                          AppColors.textMuted,
                          AppColors.textMuted.withOpacity(0.8),
                        ],
                      )
                          : const LinearGradient(
                        colors: [
                          AppColors.success,
                          Color(0xFF059669),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive && !workoutService.isSetTimerActive
                          ? [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: MaterialButton(
                      onPressed: isActive && workoutService.isSetTimerActive
                          ? null
                          : () => _startSet(index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('start_set'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isActive && workoutService.isSetTimerActive
                          ? const LinearGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF2563EB),
                        ],
                      )
                          : LinearGradient(
                        colors: [
                          AppColors.textMuted,
                          AppColors.textMuted.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive && workoutService.isSetTimerActive
                          ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: MaterialButton(
                      onPressed: isActive && workoutService.isSetTimerActive
                          ? () => _completeSet(index, workoutExercise)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('complete'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              Icon(
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        loc.get('or_enter_manually'),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
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
                    child: OutlineButton(
                      text: loc.get('cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
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



// Exercise Selection Dialog with Search and localization
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

  // Get unique muscle groups from exercises
  List<MuscleCategory> get _availableCategories => MuscleCategory.values;


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
                      Icon(
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
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: Icon(
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
                        borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
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
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.get('no_exercises_found'),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.get('try_different_filters'),
                      style: TextStyle(
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
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
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