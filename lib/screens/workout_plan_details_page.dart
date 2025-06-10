// lib/screens/workout_plan_details_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/active_workout_service.dart';
import '../widgets/custom_widgets.dart';
import 'create_workout_plan_page.dart';
import '../models/exercise.dart';

class WorkoutPlanDetailsPage extends StatefulWidget {
  final WorkoutPlan plan;

  const WorkoutPlanDetailsPage({
    Key? key,
    required this.plan,
  }) : super(key: key);

  @override
  State<WorkoutPlanDetailsPage> createState() => _WorkoutPlanDetailsPageState();
}

class _WorkoutPlanDetailsPageState extends State<WorkoutPlanDetailsPage> {
  final DatabaseService _db = DatabaseService.instance;
  late WorkoutPlan _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: Text(
          _plan.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.surface,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editPlan();
                  break;
                case 'delete':
                  _deletePlan();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      loc.currentLanguage == 'ru' ? 'Редактировать' : 'Edit',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Text(
                      loc.get('delete'),
                      style: const TextStyle(color: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(loc),
            _buildExercisesList(loc),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: GradientButton(
          text: loc.currentLanguage == 'ru'
              ? 'НАЧАТЬ ТРЕНИРОВКУ'
              : 'START WORKOUT',
          icon: Icons.play_arrow,
          onPressed: _startWorkout,
          width: 220,
          height: 60,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(LocalizationService loc) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed.withOpacity(0.1),
            AppColors.darkRed.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_plan.description != null) ...[
            Text(
              _plan.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.fitness_center,
                value: '${_plan.exercises.length}',
                label: loc.currentLanguage == 'ru' ? 'Упражнений' : 'Exercises',
              ),
              _buildStatItem(
                icon: Icons.format_list_numbered,
                value: '${_plan.totalSets}',
                label: loc.currentLanguage == 'ru' ? 'Подходов' : 'Sets',
              ),
              _buildStatItem(
                icon: Icons.timer,
                value: '~${_plan.estimatedDuration}',
                label: loc.currentLanguage == 'ru' ? 'минут' : 'minutes',
              ),
            ],
          ),

          if (_plan.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _plan.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )).toList(),
            ),
          ],

          if (_plan.timesUsed > 0 || _plan.lastUsedAt != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_plan.timesUsed > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.currentLanguage == 'ru'
                            ? 'Выполнено ${_plan.timesUsed} раз'
                            : 'Completed ${_plan.timesUsed} times',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (_plan.lastUsedAt != null)
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_plan.lastUsedAt!, loc),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryRed,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(LocalizationService loc) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _plan.exercises.length,
      itemBuilder: (context, index) {
        final exercise = _plan.exercises[index];
        return _buildExerciseCard(exercise, index + 1, loc);
      },
    );
  }

  Widget _buildExerciseCard(PlannedExercise plannedExercise, int orderNumber, LocalizationService loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GymCard(
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.darkRed],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  orderNumber.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              plannedExercise.exercise.getLocalizedName(loc.currentLanguage),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildMuscleGroupsDisplay(plannedExercise.exercise, loc),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plannedExercise.plannedSets.length} ${loc.currentLanguage == 'ru' ? 'подходов' : 'sets'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (_getTotalVolume(plannedExercise) > 0) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getTotalVolume(plannedExercise).toStringAsFixed(0)} ${loc.currentLanguage == 'ru' ? 'кг' : 'kg'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sets
                    ...plannedExercise.plannedSets.asMap().entries.map((entry) {
                      final setNumber = entry.key + 1;
                      final set = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  setNumber.toString(),
                                  style: const TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                set.targetWeight != null
                                    ? '${set.targetWeight} ${loc.currentLanguage == 'ru' ? 'кг' : 'kg'} × ${set.targetReps} ${loc.currentLanguage == 'ru' ? 'повт' : 'reps'}'
                                    : '${set.targetReps} ${loc.currentLanguage == 'ru' ? 'повторений' : 'reps'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${set.restSeconds}${loc.currentLanguage == 'ru' ? 'с' : 's'}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    if (plannedExercise.notes != null && plannedExercise.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              plannedExercise.notes!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupsDisplay(Exercise exercise, LocalizationService loc) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        // Primary muscle
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 12,
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
        // Secondary muscles
        ...exercise.secondaryMuscles.map((muscle) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(12),
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

  double _getTotalVolume(PlannedExercise exercise) {
    double total = 0;
    for (var set in exercise.plannedSets) {
      if (set.targetWeight != null) {
        total += set.targetWeight! * set.targetReps;
      }
    }
    return total;
  }

  void _startWorkout() {
    final workoutService = context.read<ActiveWorkoutService>();
    final loc = context.read<LocalizationService>();

    if (workoutService.isWorkoutActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.currentLanguage == 'ru'
                ? 'Тренировка уже активна'
                : 'Workout already active',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Start workout
    workoutService.startWorkout();

    // Add exercises from plan
    for (var plannedExercise in _plan.exercises) {
      workoutService.addExercise(plannedExercise.exercise);
    }

    // Mark plan as used
    _db.markPlanAsUsed(_plan.id);

    // Navigate to workout page
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.currentLanguage == 'ru'
              ? 'Тренировка начата!'
              : 'Workout started!',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _editPlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkoutPlanPage(
          template: _plan,
        ),
      ),
    );

    if (result == true) {
      // Reload plan
      final updatedPlan = await _db.getWorkoutPlan(_plan.id);
      if (updatedPlan != null) {
        setState(() {
          _plan = updatedPlan;
        });
      }
    }
  }

  void _deletePlan() async {
    final loc = context.read<LocalizationService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          loc.currentLanguage == 'ru'
              ? 'Удалить план?'
              : 'Delete plan?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          loc.get('action_cannot_be_undone'),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              loc.get('delete'),
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _db.deleteWorkoutPlan(_plan.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.currentLanguage == 'ru'
                  ? 'План удален'
                  : 'Plan deleted',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date, LocalizationService loc) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return loc.currentLanguage == 'ru' ? 'Сегодня' : 'Today';
    } else if (difference.inDays == 1) {
      return loc.currentLanguage == 'ru' ? 'Вчера' : 'Yesterday';
    } else if (difference.inDays < 7) {
      return loc.currentLanguage == 'ru'
          ? '${difference.inDays} дней назад'
          : '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}