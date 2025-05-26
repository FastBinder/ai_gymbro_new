// lib/screens/workout_details_page.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../widgets/custom_widgets.dart';

class WorkoutDetailsPage extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsPage({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          workout.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primaryRed),
            onPressed: () => _shareWorkout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildExercisesList(context),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: GradientButton(
          text: 'Repeat Workout',
          icon: Icons.replay,
          onPressed: () => _repeatWorkout(context),
          width: 200,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(workout.date),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(workout.date),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 20,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(workout.duration),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          _buildStatsSummary(),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    int totalSets = 0;
    int totalReps = 0;
    double totalWeight = 0;

    for (var exercise in workout.exercises) {
      totalSets += exercise.sets.length;
      for (var set in exercise.sets) {
        totalReps += set.reps;
        totalWeight += set.weight * set.reps;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Exercises',
          workout.exercises.length.toString(),
          Icons.fitness_center,
        ),
        _buildStatItem(
          'Sets',
          totalSets.toString(),
          Icons.format_list_numbered,
        ),
        _buildStatItem(
          'Reps',
          totalReps.toString(),
          Icons.repeat,
        ),
        _buildStatItem(
          'Volume',
          '${totalWeight.toStringAsFixed(0)} kg',
          Icons.show_chart,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = workout.exercises[index];
        return _buildExerciseCard(context, exercise, index + 1);
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutExercise exercise, int orderNumber) {
    // Calculate exercise stats
    int totalReps = 0;
    double maxWeight = 0;
    double totalVolume = 0;

    for (var set in exercise.sets) {
      totalReps += set.reps;
      if (set.weight > maxWeight) maxWeight = set.weight;
      totalVolume += set.weight * set.reps;
    }

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
              exercise.exercise.name,
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
                _buildMuscleGroupsDisplay(exercise.exercise),
                const SizedBox(height: 8),
                Text(
                  '${exercise.sets.length} sets • ${totalReps} reps • ${totalVolume.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
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
                    ...exercise.sets.asMap().entries.map((entry) {
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
                                '${set.weight} kg × ${set.reps} reps',
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
                              child: Text(
                                '${(set.weight * set.reps).toStringAsFixed(0)} kg',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (exercise.sets.length > 1) ...[
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Best Set: ${maxWeight} kg',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                size: 18,
                                color: AppColors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Avg: ${(totalVolume / exercise.sets.length).toStringAsFixed(0)} kg/set',
                                style: TextStyle(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
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

  Widget _buildMuscleGroupsDisplay(Exercise exercise) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        // Основная группа мышц
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
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(12),
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

  void _shareWorkout(BuildContext context) {
    // Generate workout summary text
    final buffer = StringBuffer();
    buffer.writeln('💪 AI GymBro - Workout Summary');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📅 ${_formatDate(workout.date)} at ${_formatTime(workout.date)}');
    buffer.writeln('⏱️ Duration: ${_formatDuration(workout.duration)}');
    buffer.writeln('');

    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;

    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      buffer.writeln('${i + 1}. ${exercise.exercise.name}');
      buffer.writeln('   ${exercise.exercise.muscleGroupsDisplay}');

      for (var j = 0; j < exercise.sets.length; j++) {
        final set = exercise.sets[j];
        buffer.writeln('   Set ${j + 1}: ${set.weight} kg × ${set.reps} reps');
        totalSets++;
        totalReps += set.reps;
        totalVolume += set.weight * set.reps;
      }
      buffer.writeln('');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📊 Total: ${workout.exercises.length} exercises, $totalSets sets, $totalReps reps');
    buffer.writeln('💪 Volume: ${totalVolume.toStringAsFixed(0)} kg');

    // Use share_plus to share
    Share.share(
      buffer.toString(),
      subject: 'AI GymBro - ${workout.name}',
    );
  }

  void _repeatWorkout(BuildContext context) {
    // TODO: Navigate to workout page with pre-filled exercises
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Repeat workout feature coming soon!'),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}