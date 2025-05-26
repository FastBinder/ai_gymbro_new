// lib/screens/workout_details_page.dart

import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class WorkoutDetailsPage extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsPage({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareWorkout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(),
            _buildExercisesList(context),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _repeatWorkout(context),
        icon: const Icon(Icons.replay),
        label: const Text('Repeat Workout'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(workout.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatTime(workout.date),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(workout.duration),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        _buildStatItem('Exercises', workout.exercises.length.toString()),
        _buildStatItem('Sets', totalSets.toString()),
        _buildStatItem('Reps', totalReps.toString()),
        _buildStatItem('Volume', '${totalWeight.toStringAsFixed(0)} kg'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            orderNumber.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          exercise.exercise.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${exercise.sets.length} sets • ${totalReps} reps • ${totalVolume.toStringAsFixed(0)} kg total',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muscle Group: ${exercise.exercise.muscleGroup}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...exercise.sets.asMap().entries.map((entry) {
                  final setNumber = entry.key + 1;
                  final set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            'Set $setNumber',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${set.weight} kg × ${set.reps} reps',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          '${(set.weight * set.reps).toStringAsFixed(0)} kg',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (exercise.sets.length > 1) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Best Set: ${maxWeight} kg',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Avg: ${(totalVolume / exercise.sets.length).toStringAsFixed(0)} kg/set',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareWorkout(BuildContext context) {
    // Generate workout summary text
    final buffer = StringBuffer();
    buffer.writeln('Workout: ${workout.name}');
    buffer.writeln('Date: ${_formatDate(workout.date)}');
    buffer.writeln('Duration: ${_formatDuration(workout.duration)}');
    buffer.writeln('');

    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      buffer.writeln('${i + 1}. ${exercise.exercise.name}');
      for (var j = 0; j < exercise.sets.length; j++) {
        final set = exercise.sets[j];
        buffer.writeln('   Set ${j + 1}: ${set.weight} kg × ${set.reps} reps');
      }
      buffer.writeln('');
    }

    // TODO: Implement actual sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing feature coming soon!')),
    );
  }

  void _repeatWorkout(BuildContext context) {
    // TODO: Navigate to workout page with pre-filled exercises
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Repeat workout feature coming soon!')),
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