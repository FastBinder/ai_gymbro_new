// lib/screens/exercises_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../widgets/add_custom_exercise_dialog.dart';
import '../widgets/custom_widgets.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({Key? key}) : super(key: key);

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> with TickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  List<Exercise> _exercises = [];
  MuscleCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadExercises();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _db.getAllExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exercises: $e')),
      );
    }
  }

  List<Exercise> get _filteredExercises {
    return _exercises.where((exercise) {
      final matchesCategory = _selectedCategory == null ||
          exercise.involvesCategory(_selectedCategory!);
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Иконки для категорий мышц
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

  String _getLocalizedMuscleDisplay(Exercise exercise, LocalizationService loc) {
    final primary = loc.get(exercise.primaryMuscle.localizationKey);
    if (exercise.secondaryMuscles.isEmpty) {
      return primary;
    }
    final secondary = exercise.secondaryMuscles
        .map((m) => loc.get(m.localizationKey))
        .join(', ');
    return '$primary ($secondary)';
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Column(
      children: [
        _buildHeader(),
        if (!_isLoading) _buildCategoryFilter(),
        Expanded(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          )
              : FadeTransition(
            opacity: _fadeAnimation,
            child: _filteredExercises.isEmpty
                ? EmptyState(
              icon: Icons.search_off,
              title: loc.get('no_exercises_found'),
              subtitle: loc.get('try_different_filters'),
              action: GradientButton(
                text: loc.get('add_custom_exercise'),
                icon: Icons.add,
                onPressed: _addCustomExercise,
                width: 200,
              ),
            )
                : _buildExercisesList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final loc = context.watch<LocalizationService>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GymTextField(
        hintText: loc.get('search_exercises'),
        prefixIcon: Icons.search,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }


  Widget _buildCategoryFilter() {
    final loc = context.watch<LocalizationService>();

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MuscleCategory.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategoryChip(
              label: loc.get('all'),
              isSelected: _selectedCategory == null,
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
            );
          }

          final category = MuscleCategory.values[index - 1];
          return CategoryChip(
            label: loc.get(category.localizationKey),
            isSelected: category == _selectedCategory,
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildExercisesList() {
    final loc = context.watch<LocalizationService>();

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: _filteredExercises.length,
          itemBuilder: (context, index) {
            final exercise = _filteredExercises[index];
            final isCustom = exercise.id.length > 10;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GymCard(
                onTap: () => _showExerciseDetails(exercise),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCustom
                              ? [AppColors.orange.withOpacity(0.2), AppColors.orange.withOpacity(0.1)]
                              : [AppColors.primaryRed.withOpacity(0.2), AppColors.darkRed.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isCustom ? Icons.person : _getCategoryIcon(exercise.primaryCategory),
                        color: isCustom ? AppColors.orange : AppColors.primaryRed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.getLocalizedName(loc.currentLanguage),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isCustom)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    loc.get('custom'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.orange,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getLocalizedMuscleDisplay(exercise, loc),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 28,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryRed, AppColors.darkRed],
              ),
              shape: BoxShape.circle,
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
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _addCustomExercise,
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _addCustomExercise() {
    final loc = context.read<LocalizationService>();

    showDialog(
      context: context,
      builder: (context) => AddCustomExerciseDialog(
        onAdd: (exercise) async {
          try {
            await _db.createCustomExercise(exercise);
            await _loadExercises();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.getFormatted('added_to_exercises', {'name': exercise.name})),
                backgroundColor: AppColors.success,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding exercise: $e'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        },
      ),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    final loc = context.read<LocalizationService>(); // Изменено с watch на read
    final isCustom = exercise.id.length > 10;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Container( // Переименовали context в modalContext
        height: MediaQuery.of(modalContext).size.height * 0.75,
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCustom
                                  ? [AppColors.orange.withOpacity(0.2), AppColors.orange.withOpacity(0.1)]
                                  : [AppColors.primaryRed.withOpacity(0.2), AppColors.darkRed.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isCustom ? Icons.person : _getCategoryIcon(exercise.primaryCategory),
                            color: isCustom ? AppColors.orange : AppColors.primaryRed,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exercise.getLocalizedName(loc.currentLanguage),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isCustom)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.orange,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        loc.get('custom'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildMuscleDisplay(exercise),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.get('description'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exercise.getLocalizedDescription(loc.currentLanguage),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (exercise.getLocalizedInstructions(loc.currentLanguage) != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.get('instructions'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...exercise.getLocalizedInstructions(loc.currentLanguage)!.map((instruction) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.primaryRed,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      instruction,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                    if (exercise.getLocalizedTips(loc.currentLanguage) != null) ...[
                      const SizedBox(height: 16),
                      Container(
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
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.primaryRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loc.get('pro_tips'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryRed,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...exercise.getLocalizedTips(loc.currentLanguage)!.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (isCustom)
                          Expanded(
                            child: OutlineButton(
                              text: loc.get('delete'),
                              icon: Icons.delete_outline,
                              borderColor: AppColors.warning,
                              onPressed: () => _deleteCustomExercise(exercise),
                            ),
                          ),
                        if (isCustom) const SizedBox(width: 16),
                        Expanded(
                          child: GradientButton(
                            text: loc.get('close'),
                            onPressed: () => Navigator.of(modalContext).pop(), // Используем modalContext
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleDisplay(Exercise exercise) {
    final loc = context.read<LocalizationService>();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Основная мышца
        Container(
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Вспомогательные мышцы
        ...exercise.secondaryMuscles.map((muscle) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
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
              fontSize: 12,
            ),
          ),
        )),
      ],
    );
  }

  void _deleteCustomExercise(Exercise exercise) {
    final loc = context.read<LocalizationService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          loc.get('delete_custom_exercise'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          loc.getFormatted('are_you_sure_delete', {'name': exercise.name}),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              try {
                await _db.deleteExercise(exercise.id);
                await _loadExercises();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.get('exercise_deleted')),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting exercise: $e'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: Text(
              loc.get('delete'),
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}