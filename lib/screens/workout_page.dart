// lib/screens/workout_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../widgets/add_set_dialog.dart';
import '../services/database_service.dart';
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

  // Workout data
  List<Workout> _workouts = [];
  bool _isWorkoutActive = false;
  List<WorkoutExercise> _currentExercises = [];
  bool _isLoading = true;

  // Timers
  DateTime? _workoutStartTime;
  DateTime? _restStartTime;
  DateTime? _setStartTime;
  Timer? _timer;

  // Current exercise tracking
  int? _activeExerciseIndex;
  bool _isRestTimerActive = false;
  bool _isSetTimerActive = false;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final workouts = await _db.getAllWorkouts();
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading workouts: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  // Получить иконку для группы мышц
  IconData _getMuscleGroupIcon(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return Icons.airline_seat_flat;
      case MuscleGroup.back:
      case MuscleGroup.lats:
      case MuscleGroup.middleBack:
      case MuscleGroup.lowerBack:
        return Icons.accessibility_new;
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
        return Icons.fitness_center;
      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return Icons.directions_run;
      case MuscleGroup.shoulders:
      case MuscleGroup.frontDelts:
      case MuscleGroup.sideDelts:
      case MuscleGroup.rearDelts:
        return Icons.accessibility;
      case MuscleGroup.abs:
      case MuscleGroup.obliques:
        return Icons.self_improvement;
      case MuscleGroup.traps:
        return Icons.terrain;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              color: AppColors.primaryRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'WORKOUTS',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: _isWorkoutActive ? _buildActiveWorkout() : _buildWorkoutList(),
      floatingActionButton: !_isWorkoutActive
          ? Container(
        height: 64,
        width: 200,
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
                children: const [
                  Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'START WORKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildWorkoutList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      );
    }

    if (_workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
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
                size: 80,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No workouts yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first workout and crush your goals!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _workouts.length,
      itemBuilder: (context, index) {
        final workout = _workouts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GymCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutDetailsPage(workout: workout),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryRed,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(workout.duration),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.fitness_center,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.exercises.length} exercises',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => _deleteWorkout(workout.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteWorkout(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Workout?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _db.deleteWorkout(id);
        await _loadWorkouts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting workout: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Widget _buildActiveWorkout() {
    return Column(
      children: [
        _buildTimersSection(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._currentExercises.asMap().entries.map((entry) =>
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
                    children: const [
                      Icon(Icons.add, color: AppColors.primaryRed),
                      SizedBox(width: 8),
                      Text(
                        'ADD EXERCISE',
                        style: TextStyle(
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

  Widget _buildTimersSection() {
    final workoutDuration = _workoutStartTime != null
        ? DateTime.now().difference(_workoutStartTime!)
        : Duration.zero;

    final restDuration = _restStartTime != null && _isRestTimerActive
        ? DateTime.now().difference(_restStartTime!)
        : Duration.zero;

    final setDuration = _setStartTime != null && _isSetTimerActive
        ? DateTime.now().difference(_setStartTime!)
        : Duration.zero;

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
                      'WORKOUT TIME',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(workoutDuration),
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
                    color: _isRestTimerActive
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isRestTimerActive
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
                            color: _isRestTimerActive
                                ? AppColors.warning
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REST',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isRestTimerActive
                                  ? AppColors.warning
                                  : AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(restDuration),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isRestTimerActive
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
                    color: _isSetTimerActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isSetTimerActive
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
                            color: _isSetTimerActive
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SET',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isSetTimerActive
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(setDuration),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isSetTimerActive
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

  Widget _buildExerciseCard(int index, WorkoutExercise workoutExercise) {
    final isActive = _activeExerciseIndex == index;

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
                        workoutExercise.exercise.name.toUpperCase(),
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
                if (isActive && _isSetTimerActive)
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
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
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
                              '${set.weight} kg × ${set.reps} reps',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(set.weight * set.reps).toStringAsFixed(0)} kg',
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
                      gradient: isActive && _isSetTimerActive
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
                      boxShadow: isActive && !_isSetTimerActive
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
                      onPressed: isActive && _isSetTimerActive
                          ? null
                          : () => _startSet(index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'START SET',
                            style: TextStyle(
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
                      gradient: isActive && _isSetTimerActive
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
                      boxShadow: isActive && _isSetTimerActive
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
                      onPressed: isActive && _isSetTimerActive
                          ? () => _completeSet(index, workoutExercise)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'COMPLETE',
                            style: TextStyle(
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
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Основная группа мышц
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
                exercise.primaryMuscle.russianName,
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Побочные группы мышц
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
            muscle.russianName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildFinishButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.surfaceLight,
            AppColors.surfaceLight.withOpacity(0),
          ],
        ),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.warning,
              AppColors.primaryRed,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: _finishWorkout,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.stop, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'FINISH WORKOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _workoutStartTime = DateTime.now();
      _currentExercises = [];
      _activeExerciseIndex = null;
      _isRestTimerActive = false;
      _isSetTimerActive = false;
    });
  }

  void _startSet(int exerciseIndex) {
    setState(() {
      _activeExerciseIndex = exerciseIndex;
      _isSetTimerActive = true;
      _isRestTimerActive = false;
      _setStartTime = DateTime.now();
      _restStartTime = null;
    });
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
          setState(() {
            workoutExercise.sets.add(WorkoutSet(
              weight: weight,
              reps: reps,
              timestamp: DateTime.now(),
            ));

            // Start rest timer
            _isSetTimerActive = false;
            _isRestTimerActive = true;
            _setStartTime = null;
            _restStartTime = DateTime.now();
          });
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
          setState(() {
            _currentExercises.add(WorkoutExercise(
              exercise: exercise,
              sets: [],
            ));
          });
        },
      ),
    );
  }

  void _finishWorkout() async {
    if (_currentExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one exercise'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Workout ${_formatDate(DateTime.now())}',
      date: DateTime.now(),
      exercises: _currentExercises,
      duration: DateTime.now().difference(_workoutStartTime!),
    );

    try {
      // Save to database
      await _db.createWorkout(workout);

      // Reload workouts
      await _loadWorkouts();

      setState(() {
        _isWorkoutActive = false;
        _workoutStartTime = null;
        _currentExercises = [];
        _activeExerciseIndex = null;
        _isRestTimerActive = false;
        _isSetTimerActive = false;
        _restStartTime = null;
        _setStartTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout saved!'),
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
}

// Updated CompleteSetDialog with dark theme
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
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'COMPLETE SET',
              style: TextStyle(
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
                        const Text(
                          'SAME AS LAST SET',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.lastWeight} kg × ${widget.lastReps} reps',
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
                      'OR ENTER MANUALLY',
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
              hintText: 'Weight (kg)',
              prefixIcon: Icons.fitness_center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            GymTextField(
              controller: _repsController,
              hintText: 'Reps',
              prefixIcon: Icons.repeat,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    text: 'Save',
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
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}

// Exercise Selection Dialog with Search
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
  MuscleGroup? _selectedMuscleFilter;

  List<Exercise> get _filteredExercises {
    return widget.exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMuscle = _selectedMuscleFilter == null ||
          exercise.primaryMuscle == _selectedMuscleFilter ||
          exercise.secondaryMuscles.contains(_selectedMuscleFilter);
      return matchesSearch && matchesMuscle;
    }).toList();
  }

  // Get unique muscle groups from exercises
  List<MuscleGroup> get _availableMuscleGroups {
    final groups = <MuscleGroup>{};
    for (final exercise in widget.exercises) {
      groups.add(exercise.primaryMuscle);
      groups.addAll(exercise.secondaryMuscles);
    }
    return groups.toList()..sort((a, b) => a.russianName.compareTo(b.russianName));
  }

  IconData _getMuscleGroupIcon(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return Icons.airline_seat_flat;
      case MuscleGroup.back:
      case MuscleGroup.lats:
      case MuscleGroup.middleBack:
      case MuscleGroup.lowerBack:
        return Icons.accessibility_new;
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
        return Icons.fitness_center;
      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return Icons.directions_run;
      case MuscleGroup.shoulders:
      case MuscleGroup.frontDelts:
      case MuscleGroup.sideDelts:
      case MuscleGroup.rearDelts:
        return Icons.accessibility;
      case MuscleGroup.abs:
      case MuscleGroup.obliques:
        return Icons.self_improvement;
      case MuscleGroup.traps:
        return Icons.terrain;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'SELECT EXERCISE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
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
                      hintText: 'Search exercises...',
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
            // Muscle Group Filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _availableMuscleGroups.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // All muscles chip
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedMuscleFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMuscleFilter = null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primaryRed.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryRed,
                        labelStyle: TextStyle(
                          color: _selectedMuscleFilter == null
                              ? AppColors.primaryRed
                              : AppColors.textSecondary,
                          fontWeight: _selectedMuscleFilter == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: _selectedMuscleFilter == null
                              ? AppColors.primaryRed
                              : AppColors.border,
                        ),
                      ),
                    );
                  }

                  final muscle = _availableMuscleGroups[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(muscle.russianName),
                      selected: _selectedMuscleFilter == muscle,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMuscleFilter = selected ? muscle : null;
                        });
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primaryRed.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryRed,
                      labelStyle: TextStyle(
                        color: _selectedMuscleFilter == muscle
                            ? AppColors.primaryRed
                            : AppColors.textSecondary,
                        fontWeight: _selectedMuscleFilter == muscle
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: _selectedMuscleFilter == muscle
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
                      'No exercises found',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try different search terms',
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
                                    : _getMuscleGroupIcon(exercise.primaryMuscle),
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
                                    exercise.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exercise.muscleGroupsDisplay,
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
}