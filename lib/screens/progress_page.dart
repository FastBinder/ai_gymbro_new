// lib/screens/progress_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/workout.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';


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
  bool _showDetailedMuscles = false; // false = basic categories, true = detailed muscles

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
    final loc = context.watch<LocalizationService>();

    return Column(
      children: [
        Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryRed,
            indicatorWeight: 3,
            labelColor: AppColors.primaryRed,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            tabs: [
              Tab(text: loc.get('this_week')),
              Tab(text: loc.get('all_time')),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
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
        ),
      ],
    );
  }


  Widget _buildWeekStats() {
    final loc = context.watch<LocalizationService>();

    if (_weekWorkouts.isEmpty) {
      return _buildEmptyState(
          loc.get('no_workouts_this_week'),
          loc.get('start_training_week')
      );
    }

    final muscleStats = _showDetailedMuscles
        ? _calculateDetailedMuscleStats(_weekWorkouts)
        : _calculateCategoryStats(_weekWorkouts);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildViewModeToggle(),
          const SizedBox(height: 20),
          _buildSectionTitle(loc.get('weekly_sets_by_muscle')),
          const SizedBox(height: 16),
          if (_showDetailedMuscles)
            ..._buildDetailedMuscleCards(muscleStats as Map<DetailedMuscle, MuscleStats>)
          else
            ..._buildCategoryCards(muscleStats as Map<MuscleCategory, MuscleStats>),
        ],
      ),
    );
  }

  Widget _buildAllTimeStats() {
    final loc = context.watch<LocalizationService>();

    if (_allWorkouts.isEmpty) {
      return _buildEmptyState(
          loc.get('no_workouts_yet_progress'),
          loc.get('complete_first_workout')
      );
    }

    final muscleStats = _showDetailedMuscles
        ? _calculateDetailedMuscleStats(_allWorkouts)
        : _calculateCategoryStats(_allWorkouts);
    final exerciseProgress = _calculateExerciseProgress();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAllTimeSummaryCard(),
          const SizedBox(height: 20),
          _buildViewModeToggle(),
          const SizedBox(height: 20),
          _buildSectionTitle(loc.get('strength_progress')),
          const SizedBox(height: 16),
          ...exerciseProgress.entries.map((entry) => _buildExerciseProgressCard(entry.key, entry.value)),
          const SizedBox(height: 20),
          _buildSectionTitle(loc.get('total_sets_by_muscle')),
          const SizedBox(height: 16),
          if (_showDetailedMuscles)
            ..._buildDetailedMuscleCards(muscleStats as Map<DetailedMuscle, MuscleStats>)
          else
            ..._buildCategoryCards(muscleStats as Map<MuscleCategory, MuscleStats>),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle() {
    final loc = context.watch<LocalizationService>();

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
          Text(
            loc.get('view_mode'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showDetailedMuscles = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_showDetailedMuscles
                          ? AppColors.primaryRed.withOpacity(0.1)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_showDetailedMuscles
                            ? AppColors.primaryRed
                            : AppColors.border,
                        width: !_showDetailedMuscles ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category,
                          size: 20,
                          color: !_showDetailedMuscles
                              ? AppColors.primaryRed
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.get('basic_muscles'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: !_showDetailedMuscles
                                ? AppColors.primaryRed
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showDetailedMuscles = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _showDetailedMuscles
                          ? AppColors.primaryRed.withOpacity(0.1)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showDetailedMuscles
                            ? AppColors.primaryRed
                            : AppColors.border,
                        width: _showDetailedMuscles ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.view_list,
                          size: 20,
                          color: _showDetailedMuscles
                              ? AppColors.primaryRed
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.get('detailed_muscles'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _showDetailedMuscles
                                ? AppColors.primaryRed
                                : AppColors.textSecondary,
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
            style: const TextStyle(
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
    final loc = context.watch<LocalizationService>();

    int totalSets = 0;
    int totalReps = 0;

    for (var workout in _weekWorkouts) {
      for (var exercise in workout.exercises) {
        totalSets += exercise.sets.length;
        for (var set in exercise.sets) {
          totalReps += set.reps;
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
          Text(
            loc.get('week_summary'),
            style: const TextStyle(
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
              _buildStatItem(loc.get('workouts'), _weekWorkouts.length.toString(), Icons.calendar_today),
              _buildStatItem(loc.get('sets'), totalSets.toString(), Icons.format_list_numbered),
              _buildStatItem(loc.get('reps'), totalReps.toString(), Icons.repeat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeSummaryCard() {
    final loc = context.watch<LocalizationService>();
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

        // Calculate total sets
        int totalSets = 0;
        for (var workout in _allWorkouts) {
          for (var exercise in workout.exercises) {
            totalSets += exercise.sets.length;
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
              Text(
                loc.get('all_time_stats'),
                style: const TextStyle(
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
                  _buildStatItem(loc.get('workouts'), totalWorkouts.toString(), Icons.fitness_center),
                  _buildStatItem(loc.get('total_time'), _formatDuration(totalDuration), Icons.timer),
                  _buildStatItem(loc.get('streak'), '$streak ${loc.get('days')}', Icons.local_fire_department),
                  _buildStatItem(loc.get('sets'), totalSets.toString(), Icons.format_list_numbered),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCategoryCards(Map<MuscleCategory, MuscleStats> stats) {
    final loc = context.watch<LocalizationService>();

    return stats.entries.map((entry) {
      final category = entry.key;
      final stat = entry.value;

      // Format sets to show as integer if whole number, otherwise with one decimal
      final setsDisplay = stat.sets % 1 == 0
          ? stat.sets.toInt().toString()
          : stat.sets.toStringAsFixed(1);

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
                    _getCategoryIcon(category),
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
                        loc.get(category.localizationKey),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$setsDisplay ${loc.get('sets')} • ${stat.reps} ${loc.get('reps')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildDetailedMuscleCards(Map<DetailedMuscle, MuscleStats> stats) {
    final loc = context.watch<LocalizationService>();

    // Group by category for better organization
    final Map<MuscleCategory, List<MapEntry<DetailedMuscle, MuscleStats>>> groupedStats = {};

    for (var entry in stats.entries) {
      final category = entry.key.category;
      if (!groupedStats.containsKey(category)) {
        groupedStats[category] = [];
      }
      groupedStats[category]!.add(entry);
    }

    final List<Widget> widgets = [];

    groupedStats.forEach((category, muscles) {
      // Add category header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            loc.get(category.localizationKey),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );

      // Add muscle cards
      for (var entry in muscles) {
        final muscle = entry.key;
        final stat = entry.value;

        final setsDisplay = stat.sets % 1 == 0
            ? stat.sets.toInt().toString()
            : stat.sets.toStringAsFixed(1);

        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GymCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(muscle.category),
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.get(muscle.localizationKey),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$setsDisplay ${loc.get('sets')} • ${stat.reps} ${loc.get('reps')}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });

    return widgets;
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

  Widget _buildExerciseProgressCard(String exerciseName, ExerciseProgress progress) {
    final loc = context.watch<LocalizationService>();

    // Получаем историю прогресса для графика
    final progressHistory = _getExerciseProgressHistory(exerciseName);

    if (progressHistory.isEmpty) return const SizedBox.shrink();

    final improvement = ((progress.currentMax - progress.firstMax) / progress.firstMax * 100);
    final isPositive = improvement >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GymCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с названием упражнения
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exerciseName,
                      style: const TextStyle(
                        fontSize: 18,
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
                          '${improvement > 0 ? '+' : ''}${improvement.toStringAsFixed(1)}%',
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
              const SizedBox(height: 16),

              // График
              SizedBox(
                height: 200,
                child: _buildProgressChart(progressHistory, loc),
              ),

              const SizedBox(height: 16),

              // Статистика
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    loc.get('first'),
                    '${progress.firstMax.toStringAsFixed(1)} ${loc.currentLanguage == 'ru' ? 'кг' : 'kg'}',
                    AppColors.textSecondary,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  _buildStatColumn(
                    loc.get('current'),
                    '${progress.currentMax.toStringAsFixed(1)} ${loc.currentLanguage == 'ru' ? 'кг' : 'kg'}',
                    isPositive ? AppColors.success : AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  loc.getFormatted('performed_times', {'count': progress.timesPerformed}),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChart(List<ExerciseRecord> history, LocalizationService loc) {
    if (history.isEmpty) return const SizedBox.shrink();

    // Сортируем по дате
    history.sort((a, b) => a.date.compareTo(b.date));

    // Находим минимальное и максимальное значения для оси Y
    double minY = history.map((e) => e.oneRepMax).reduce((a, b) => a < b ? a : b);
    double maxY = history.map((e) => e.oneRepMax).reduce((a, b) => a > b ? a : b);

    // Добавляем отступы
    minY = (minY * 0.9).floorToDouble();
    maxY = (maxY * 1.1).ceilToDouble();

    // Создаем точки для графика
    final spots = history.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.oneRepMax,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < history.length) {
                  final date = history[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        minX: 0,
        maxX: (history.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryRed,
                AppColors.darkRed,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primaryRed,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryRed.withOpacity(0.3),
                  AppColors.primaryRed.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surface,
              tooltipBorder: BorderSide(color: AppColors.primaryRed),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < history.length) {
                    final record = history[index];
                    return LineTooltipItem(
                      '${record.oneRepMax.toStringAsFixed(1)} ${loc.currentLanguage == 'ru' ? 'кг' : 'kg'}\n${DateFormat('dd.MM.yyyy').format(record.date)}',
                      TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  List<ExerciseRecord> _getExerciseProgressHistory(String exerciseName) {
    final records = <ExerciseRecord>[];

    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        if (exercise.exercise.name == exerciseName && exercise.sets.isNotEmpty) {
          // Находим максимальный 1RM для этой тренировки
          double max1RM = 0;
          for (var set in exercise.sets) {
            double oneRepMax = set.weight * (1 + set.reps / 30.0);
            if (oneRepMax > max1RM) {
              max1RM = oneRepMax;
            }
          }

          if (max1RM > 0) {
            records.add(ExerciseRecord(
              oneRepMax: max1RM,
              date: workout.date,
            ));
          }
        }
      }
    }

    return records;
  }

  Map<MuscleCategory, MuscleStats> _calculateCategoryStats(List<Workout> workouts) {
    final stats = <MuscleCategory, MuscleStats>{};

    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        // Primary muscle category - full credit
        final primaryCategory = exercise.exercise.primaryCategory;
        if (!stats.containsKey(primaryCategory)) {
          stats[primaryCategory] = MuscleStats();
        }

        final primaryStats = stats[primaryCategory]!;
        primaryStats.sets += exercise.sets.length; // 1 point per set

        for (var set in exercise.sets) {
          primaryStats.reps += set.reps;
          primaryStats.volume += set.weight * set.reps;
        }

        // Secondary muscles categories - half credit
        for (var muscle in exercise.exercise.secondaryMuscles) {
          final category = muscle.category;
          if (!stats.containsKey(category)) {
            stats[category] = MuscleStats();
          }

          final secondaryStats = stats[category]!;
          secondaryStats.sets += exercise.sets.length * 0.5; // 0.5 points per set

          for (var set in exercise.sets) {
            secondaryStats.reps += set.reps;
            secondaryStats.volume += (set.weight * set.reps) * 0.5; // 50% volume
          }
        }
      }
    }

    // Sort by sets instead of volume
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.sets.compareTo(a.value.sets));

    return Map.fromEntries(sortedEntries);
  }

  Map<DetailedMuscle, MuscleStats> _calculateDetailedMuscleStats(List<Workout> workouts) {
    final stats = <DetailedMuscle, MuscleStats>{};

    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        // Primary muscle - full credit
        final primaryMuscle = exercise.exercise.primaryMuscle;
        if (!stats.containsKey(primaryMuscle)) {
          stats[primaryMuscle] = MuscleStats();
        }

        final primaryStats = stats[primaryMuscle]!;
        primaryStats.sets += exercise.sets.length; // 1 point per set

        for (var set in exercise.sets) {
          primaryStats.reps += set.reps;
          primaryStats.volume += set.weight * set.reps;
        }

        // Secondary muscles - half credit
        for (var muscle in exercise.exercise.secondaryMuscles) {
          if (!stats.containsKey(muscle)) {
            stats[muscle] = MuscleStats();
          }

          final secondaryStats = stats[muscle]!;
          secondaryStats.sets += exercise.sets.length * 0.5; // 0.5 points per set

          for (var set in exercise.sets) {
            secondaryStats.reps += set.reps;
            secondaryStats.volume += (set.weight * set.reps) * 0.5; // 50% volume
          }
        }
      }
    }

    // Sort by category and then by sets within category
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) {
        final categoryCompare = a.key.category.index.compareTo(b.key.category.index);
        if (categoryCompare != 0) return categoryCompare;
        return b.value.sets.compareTo(a.value.sets);
      });

    return Map.fromEntries(sortedEntries);
  }

  Map<String, ExerciseProgress> _calculateExerciseProgress() {
    final exerciseData = <String, List<ExerciseRecord>>{};

    // Collect all records for each exercise
    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        if (!exerciseData.containsKey(exercise.exercise.name)) {
          exerciseData[exercise.exercise.name] = [];
        }

        // Find max 1RM for this workout
        double max1RM = 0;
        for (var set in exercise.sets) {
          // Epley formula: 1RM = weight × (1 + reps / 30)
          double oneRepMax = set.weight * (1 + set.reps / 30.0);
          if (oneRepMax > max1RM) {
            max1RM = oneRepMax;
          }
        }

        if (max1RM > 0) {
          exerciseData[exercise.exercise.name]!.add(
            ExerciseRecord(
              oneRepMax: max1RM,
              date: workout.date,
            ),
          );
        }
      }
    }

    // Calculate progress for exercises performed at least twice
    final progress = <String, ExerciseProgress>{};

    exerciseData.forEach((name, records) {
      if (records.length >= 2) {
        // Sort by date (oldest to newest)
        records.sort((a, b) => a.date.compareTo(b.date));

        progress[name] = ExerciseProgress(
          firstMax: records.first.oneRepMax,
          currentMax: records.last.oneRepMax,
          timesPerformed: records.length,
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

  String _formatDuration(Duration duration) {
    final loc = context.read<LocalizationService>();
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}${loc.currentLanguage == 'ru' ? 'ч' : 'h'} ${minutes}${loc.currentLanguage == 'ru' ? 'м' : 'm'}';
    } else {
      return '${minutes}${loc.currentLanguage == 'ru' ? 'м' : 'm'}';
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

// Helper class for storing exercise records
class ExerciseRecord {
  final double oneRepMax;
  final DateTime date;

  ExerciseRecord({
    required this.oneRepMax,
    required this.date,
  });
}