// lib/screens/progress_page.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/workout.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/muscle_body_visualization.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  late TabController _tabController;

  List<Workout> _allWorkouts = [];
  List<Workout> _weekWorkouts = [];
  bool _isLoading = true;
  TrainingLevel _selectedLevel = TrainingLevel.intermediate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final allWorkouts = await _db.getAllWorkouts();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      setState(() {
        _allWorkouts = allWorkouts;
        _weekWorkouts = allWorkouts.where((workout) {
          return workout.date.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
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
              Icons.analytics,
              color: AppColors.primaryRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'PROGRESS',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          indicatorWeight: 3,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'THIS WEEK'),
            Tab(text: 'ALL TIME'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildWeekStats(),
          _buildAllTimeStats(),
        ],
      ),
    );
  }

  Widget _buildWeekStats() {
    if (_weekWorkouts.isEmpty) {
      return _buildEmptyState('No workouts this week', 'Start training to see your weekly progress!');
    }

    final muscleStats = _calculateMuscleStats(_weekWorkouts);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildTrainingLevelSelector(),
          const SizedBox(height: 20),
          _buildComingSoonCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Weekly Sets by Muscle Group'),
          const SizedBox(height: 16),
          ...muscleStats.entries.map((entry) => _buildMuscleSetCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildAllTimeStats() {
    if (_allWorkouts.isEmpty) {
      return _buildEmptyState('No workouts yet', 'Complete your first workout to see progress!');
    }

    final muscleStats = _calculateMuscleStats(_allWorkouts);
    final exerciseProgress = _calculateExerciseProgress();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAllTimeSummaryCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Strength Progress'),
          const SizedBox(height: 16),
          ...exerciseProgress.entries.map((entry) => _buildExerciseProgressCard(entry.key, entry.value)),
          const SizedBox(height: 20),
          _buildSectionTitle('Total Sets by Muscle Group'),
          const SizedBox(height: 16),
          ...muscleStats.entries.map((entry) => _buildMuscleSetCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 100,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;

    for (var workout in _weekWorkouts) {
      for (var exercise in workout.exercises) {
        totalSets += exercise.sets.length;
        for (var set in exercise.sets) {
          totalReps += set.reps;
          totalVolume += set.weight * set.reps;
        }
      }
    }

    return Container(
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
        children: [
          const Text(
            'WEEK SUMMARY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Workouts', _weekWorkouts.length.toString(), Icons.calendar_today),
              _buildStatItem('Sets', totalSets.toString(), Icons.format_list_numbered),
              _buildStatItem('Reps', totalReps.toString(), Icons.repeat),
              _buildStatItem('Volume', '${totalVolume.toStringAsFixed(0)} kg', Icons.fitness_center),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeSummaryCard() {
    final stats = _db.getStatistics();

    return FutureBuilder<Map<String, dynamic>>(
      future: stats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final totalWorkouts = data['totalWorkouts'] as int;
        final totalDuration = data['totalDuration'] as Duration;
        final streak = data['currentStreak'] as int;

        // Calculate total volume
        double totalVolume = 0;
        int totalSets = 0;
        for (var workout in _allWorkouts) {
          for (var exercise in workout.exercises) {
            totalSets += exercise.sets.length;
            for (var set in exercise.sets) {
              totalVolume += set.weight * set.reps;
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.success.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'ALL TIME STATS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Workouts', totalWorkouts.toString(), Icons.fitness_center),
                  _buildStatItem('Total Time', _formatDuration(totalDuration), Icons.timer),
                  _buildStatItem('Streak', '$streak days', Icons.local_fire_department),
                  _buildStatItem('Total Sets', totalSets.toString(), Icons.format_list_numbered),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingLevelSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'УРОВЕНЬ ПОДГОТОВКИ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: TrainingLevel.values.map((level) {
              final isSelected = _selectedLevel == level;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLevel = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryRed.withOpacity(0.1)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryRed
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            level.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${level.minSets}-${level.maxSets} сетов',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.accessibility_new,
              size: 64,
              color: AppColors.primaryRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'MUSCLE VISUALIZATION',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'COMING SOON',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Visual body representation with muscle group highlights',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleSetCard(MuscleGroup muscle, MuscleStats stats) {
    // Format sets to show as integer if whole number, otherwise with one decimal
    final setsDisplay = stats.sets % 1 == 0
        ? stats.sets.toInt().toString()
        : stats.sets.toStringAsFixed(1);

    final percentage = (stats.sets / _selectedLevel.maxSets * 100).clamp(0, 100);
    final color = _getColorForSets(stats.sets);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GymCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMuscleGroupIcon(muscle),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscle.russianName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target: ${_selectedLevel.minSets}-${_selectedLevel.maxSets} sets',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            setsDisplay,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            ' sets',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}% of max',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForSets(double sets) {
    if (sets < _selectedLevel.minSets) {
      return AppColors.warning;
    } else if (sets <= _selectedLevel.maxSets) {
      return AppColors.success;
    } else {
      return AppColors.orange;
    }
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
            fontSize: 18,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMuscleDistributionChart(Map<MuscleGroup, MuscleStats> stats) {
    final total = stats.values.fold(0.0, (sum, stat) => sum + stat.sets);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            child: CustomPaint(
              painter: PieChartPainter(
                data: stats.map((muscle, stat) => MapEntry(
                  muscle.russianName,
                  stat.sets / total,
                )),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: stats.entries.map((entry) {
                  final percentage = (entry.value.sets / total * 100).toStringAsFixed(1);
                  final color = _getColorForIndex(stats.keys.toList().indexOf(entry.key));

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${entry.key.russianName} ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleVolumeCard(MuscleGroup muscle, MuscleStats stats) {
    // Format sets to show as integer if whole number, otherwise with one decimal
    final setsDisplay = stats.sets % 1 == 0
        ? stats.sets.toInt().toString()
        : stats.sets.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GymCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMuscleGroupIcon(muscle),
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
                      muscle.russianName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$setsDisplay sets • ${stats.reps} reps',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stats.volume.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  Text(
                    'total volume',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseProgressCard(String exerciseName, ExerciseProgress progress) {
    final improvement = ((progress.currentMax - progress.firstMax) / progress.firstMax * 100);
    final isPositive = improvement >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GymCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exerciseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isPositive ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${improvement.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${progress.firstMax} kg',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${progress.currentMax} kg',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Performed ${progress.timesPerformed} times',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<MuscleGroup, MuscleStats> _calculateMuscleStats(List<Workout> workouts) {
    final stats = <MuscleGroup, MuscleStats>{};

    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        // Primary muscle - full credit for sets
        if (!stats.containsKey(exercise.exercise.primaryMuscle)) {
          stats[exercise.exercise.primaryMuscle] = MuscleStats();
        }

        final primaryStats = stats[exercise.exercise.primaryMuscle]!;
        primaryStats.sets += exercise.sets.length; // 1 point per set

        for (var set in exercise.sets) {
          primaryStats.reps += set.reps;
          primaryStats.volume += set.weight * set.reps;
        }

        // Secondary muscles - half credit for sets
        for (var muscle in exercise.exercise.secondaryMuscles) {
          if (!stats.containsKey(muscle)) {
            stats[muscle] = MuscleStats();
          }

          final secondaryStats = stats[muscle]!;
          secondaryStats.sets += exercise.sets.length * 0.5; // 0.5 points per set

          for (var set in exercise.sets) {
            secondaryStats.reps += set.reps;
            secondaryStats.volume += (set.weight * set.reps) * 0.5; // 50% volume for secondary
          }
        }
      }
    }

    // Sort by volume
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.volume.compareTo(a.value.volume));

    return Map.fromEntries(sortedEntries);
  }

  Map<String, ExerciseProgress> _calculateExerciseProgress() {
    final exerciseData = <String, List<double>>{};

    // Collect all max weights for each exercise
    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        if (!exerciseData.containsKey(exercise.exercise.name)) {
          exerciseData[exercise.exercise.name] = [];
        }

        double maxWeight = 0;
        for (var set in exercise.sets) {
          if (set.weight > maxWeight) {
            maxWeight = set.weight;
          }
        }

        if (maxWeight > 0) {
          exerciseData[exercise.exercise.name]!.add(maxWeight);
        }
      }
    }

    // Calculate progress for exercises performed at least twice
    final progress = <String, ExerciseProgress>{};

    exerciseData.forEach((name, weights) {
      if (weights.length >= 2) {
        progress[name] = ExerciseProgress(
          firstMax: weights.first,
          currentMax: weights.last,
          timesPerformed: weights.length,
        );
      }
    });

    // Sort by improvement percentage
    final sortedEntries = progress.entries.toList()
      ..sort((a, b) {
        final aImprovement = (a.value.currentMax - a.value.firstMax) / a.value.firstMax;
        final bImprovement = (b.value.currentMax - b.value.firstMax) / b.value.firstMax;
        return bImprovement.compareTo(aImprovement);
      });

    return Map.fromEntries(sortedEntries);
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

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primaryRed,
      AppColors.success,
      AppColors.orange,
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
    ];

    return colors[index % colors.length];
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class MuscleStats {
  double sets = 0; // Changed from int to double
  int reps = 0;
  double volume = 0;
}

class ExerciseProgress {
  final double firstMax;
  final double currentMax;
  final int timesPerformed;

  ExerciseProgress({
    required this.firstMax,
    required this.currentMax,
    required this.timesPerformed,
  });
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final Map<String, double> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;
    int index = 0;

    data.forEach((label, value) {
      final sweepAngle = value * 2 * math.pi;
      paint.color = _getColorForIndex(index);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      index++;
    });
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primaryRed,
      AppColors.success,
      AppColors.orange,
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
    ];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}