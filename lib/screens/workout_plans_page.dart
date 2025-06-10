// lib/screens/workout_plans_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../widgets/custom_widgets.dart';
import 'create_workout_plan_page.dart';
import 'workout_plan_details_page.dart';

class WorkoutPlansPage extends StatefulWidget {
  const WorkoutPlansPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPlansPage> createState() => _WorkoutPlansPageState();
}

class _WorkoutPlansPageState extends State<WorkoutPlansPage> with TickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  List<WorkoutPlan> _plans = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPlans();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _db.getAllWorkoutPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading plans: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month,
              color: AppColors.primaryRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              loc.currentLanguage == 'ru' ? 'ПЛАНЫ ТРЕНИРОВОК' : 'WORKOUT PLANS',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: _plans.isEmpty
            ? _buildEmptyState(loc)
            : _buildPlansList(loc),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewPlan(context),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(LocalizationService loc) {
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
              Icons.event_note,
              size: 80,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.currentLanguage == 'ru'
                ? 'Нет планов тренировок'
                : 'No workout plans',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.currentLanguage == 'ru'
                ? 'Создайте свой первый план тренировки'
                : 'Create your first workout plan',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: loc.currentLanguage == 'ru'
                ? 'СОЗДАТЬ ПЛАН'
                : 'CREATE PLAN',
            icon: Icons.add,
            onPressed: () => _createNewPlan(context),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(LocalizationService loc) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length + 1, // +1 for templates header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTemplatesSection(loc);
        }

        final plan = _plans[index - 1];
        return _buildPlanCard(plan, loc);
      },
    );
  }

  Widget _buildTemplatesSection(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            loc.currentLanguage == 'ru' ? 'ШАБЛОНЫ' : 'TEMPLATES',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTemplateCard(
                title: 'Push Day',
                subtitle: loc.currentLanguage == 'ru'
                    ? 'Грудь, Плечи, Трицепс'
                    : 'Chest, Shoulders, Triceps',
                icon: Icons.north,
                onTap: () => _useTemplate(WorkoutTemplates.pushDay()),
              ),
              const SizedBox(width: 12),
              _buildTemplateCard(
                title: 'Pull Day',
                subtitle: loc.currentLanguage == 'ru'
                    ? 'Спина, Бицепс'
                    : 'Back, Biceps',
                icon: Icons.south,
                onTap: () => _useTemplate(WorkoutTemplates.pullDay()),
              ),
              const SizedBox(width: 12),
              _buildTemplateCard(
                title: 'Leg Day',
                subtitle: loc.currentLanguage == 'ru'
                    ? 'Ноги, Ягодицы'
                    : 'Legs, Glutes',
                icon: Icons.directions_run,
                onTap: () => _useTemplate(WorkoutTemplates.legDay()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            loc.currentLanguage == 'ru' ? 'МОИ ПЛАНЫ' : 'MY PLANS',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryRed.withOpacity(0.1),
              AppColors.darkRed.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryRed.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryRed,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(WorkoutPlan plan, LocalizationService loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GymCard(
        onTap: () => _openPlanDetails(plan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (plan.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            plan.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (plan.timesUsed > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${plan.timesUsed}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
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
                  _buildPlanStat(
                    icon: Icons.fitness_center,
                    value: '${plan.exercises.length}',
                    label: loc.currentLanguage == 'ru' ? 'упр.' : 'ex.',
                  ),
                  const SizedBox(width: 16),
                  _buildPlanStat(
                    icon: Icons.format_list_numbered,
                    value: '${plan.totalSets}',
                    label: loc.currentLanguage == 'ru' ? 'подх.' : 'sets',
                  ),
                  const SizedBox(width: 16),
                  _buildPlanStat(
                    icon: Icons.timer,
                    value: '~${plan.estimatedDuration}',
                    label: loc.currentLanguage == 'ru' ? 'мин' : 'min',
                  ),
                ],
              ),
              if (plan.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: plan.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              if (plan.lastUsedAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      loc.currentLanguage == 'ru'
                          ? 'Последнее использование: ${_formatDate(plan.lastUsedAt!)}'
                          : 'Last used: ${_formatDate(plan.lastUsedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _createNewPlan(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateWorkoutPlanPage(),
      ),
    );

    if (result == true) {
      _loadPlans();
    }
  }

  void _openPlanDetails(WorkoutPlan plan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutPlanDetailsPage(plan: plan),
      ),
    );

    if (result == true) {
      _loadPlans();
    }
  }

  void _useTemplate(WorkoutPlan template) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkoutPlanPage(
          template: template,
        ),
      ),
    );

    if (result == true) {
      _loadPlans();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return context.read<LocalizationService>().currentLanguage == 'ru'
          ? 'Сегодня'
          : 'Today';
    } else if (difference.inDays == 1) {
      return context.read<LocalizationService>().currentLanguage == 'ru'
          ? 'Вчера'
          : 'Yesterday';
    } else if (difference.inDays < 7) {
      return context.read<LocalizationService>().currentLanguage == 'ru'
          ? '${difference.inDays} дней назад'
          : '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}