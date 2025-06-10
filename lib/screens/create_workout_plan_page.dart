// lib/screens/create_workout_plan_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../widgets/custom_widgets.dart';

class CreateWorkoutPlanPage extends StatefulWidget {
  final WorkoutPlan? template;

  const CreateWorkoutPlanPage({
    Key? key,
    this.template,
  }) : super(key: key);

  @override
  State<CreateWorkoutPlanPage> createState() => _CreateWorkoutPlanPageState();
}

class _CreateWorkoutPlanPageState extends State<CreateWorkoutPlanPage> {
  final DatabaseService _db = DatabaseService.instance;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<PlannedExercise> _exercises = [];
  List<String> _tags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description ?? '';
      _exercises = widget.template!.exercises.map((e) => PlannedExercise(
        exercise: e.exercise,
        plannedSets: e.plannedSets.map((s) => PlannedSet(
          targetReps: s.targetReps,
          targetWeight: s.targetWeight,
          restSeconds: s.restSeconds,
        )).toList(),
        notes: e.notes,
      )).toList();
      _tags = List.from(widget.template!.tags);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          widget.template != null
              ? (loc.currentLanguage == 'ru' ? 'НАСТРОИТЬ ШАБЛОН' : 'CUSTOMIZE TEMPLATE')
              : (loc.currentLanguage == 'ru' ? 'НОВЫЙ ПЛАН' : 'NEW PLAN'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _exercises.isEmpty ? null : _savePlan,
            child: Text(
              loc.currentLanguage == 'ru' ? 'СОХРАНИТЬ' : 'SAVE',
              style: TextStyle(
                color: _exercises.isEmpty ? AppColors.textMuted : AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // План информация
            GymCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.currentLanguage == 'ru'
                          ? 'Название плана'
                          : 'Plan name',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.currentLanguage == 'ru'
                          ? 'Описание (необязательно)'
                          : 'Description (optional)',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Теги
            Text(
              loc.currentLanguage == 'ru' ? 'ТЕГИ' : 'TAGS',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._buildTagChips(),
                _buildAddTagChip(),
              ],
            ),
            const SizedBox(height: 24),

            // Упражнения
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.currentLanguage == 'ru' ? 'УПРАЖНЕНИЯ' : 'EXERCISES',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${_exercises.length} ${loc.currentLanguage == 'ru' ? 'упр.' : 'ex.'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Список упражнений
            ..._exercises.asMap().entries.map((entry) =>
                _buildExerciseCard(entry.key, entry.value, loc)
            ).toList(),

            // Кнопка добавления упражнения
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
                onPressed: _addExercise,
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
                      loc.currentLanguage == 'ru'
                          ? 'ДОБАВИТЬ УПРАЖНЕНИЕ'
                          : 'ADD EXERCISE',
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
    );
  }

  List<Widget> _buildTagChips() {
    final commonTags = ['Push', 'Pull', 'Legs', 'Upper Body', 'Lower Body', 'Strength', 'Hypertrophy'];

    return commonTags.map((tag) {
      final isSelected = _tags.contains(tag);

      return FilterChip(
        label: Text(tag),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _tags.add(tag);
            } else {
              _tags.remove(tag);
            }
          });
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryRed.withOpacity(0.2),
        checkmarkColor: AppColors.primaryRed,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryRed : AppColors.border,
        ),
      );
    }).toList();
  }

  Widget _buildAddTagChip() {
    return ActionChip(
      label: const Icon(Icons.add, size: 16),
      onPressed: _addCustomTag,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
    );
  }

  Widget _buildExerciseCard(int index, PlannedExercise plannedExercise, LocalizationService loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GymCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Drag handle
                Icon(
                  Icons.drag_handle,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plannedExercise.exercise.getLocalizedName(loc.currentLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plannedExercise.plannedSets.length} ${loc.currentLanguage == 'ru' ? 'подходов' : 'sets'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.textSecondary),
                      onPressed: () => _editExercise(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.warning),
                      onPressed: () => _removeExercise(index),
                    ),
                  ],
                ),
              ],
            ),

            // Sets preview
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: plannedExercise.plannedSets.map((set) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  set.targetWeight != null
                      ? '${set.targetWeight}kg × ${set.targetReps}'
                      : '${set.targetReps} reps',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              )).toList(),
            ),

            if (plannedExercise.notes != null && plannedExercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plannedExercise.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addExercise() async {
    final exercises = await _db.getAllExercises();

    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => _ExerciseSelectionDialog(exercises: exercises),
    );

    if (result != null) {
      setState(() {
        _exercises.add(PlannedExercise(
          exercise: result,
          plannedSets: [
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
          ],
        ));
      });
    }
  }

  void _editExercise(int index) async {
    final result = await showDialog<PlannedExercise>(
      context: context,
      builder: (context) => _EditExerciseDialog(
        plannedExercise: _exercises[index],
      ),
    );

    if (result != null) {
      setState(() {
        _exercises[index] = result;
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _addCustomTag() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          context.read<LocalizationService>().currentLanguage == 'ru'
              ? 'Добавить тег'
              : 'Add tag',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: context.read<LocalizationService>().currentLanguage == 'ru'
                ? 'Название тега'
                : 'Tag name',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.read<LocalizationService>().get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(context.read<LocalizationService>().get('save')),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _tags.add(result);
      });
    }
  }

  void _savePlan() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().currentLanguage == 'ru'
                ? 'Введите название плана'
                : 'Enter plan name',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().get('add_at_least_one_exercise'),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final plan = WorkoutPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        exercises: _exercises,
        createdAt: DateTime.now(),
        type: WorkoutPlanType.custom,
        tags: _tags,
      );

      await _db.createWorkoutPlan(plan);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().currentLanguage == 'ru'
                ? 'План сохранен'
                : 'Plan saved',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}

// Диалог выбора упражнения
class _ExerciseSelectionDialog extends StatefulWidget {
  final List<Exercise> exercises;

  const _ExerciseSelectionDialog({
    Key? key,
    required this.exercises,
  }) : super(key: key);

  @override
  State<_ExerciseSelectionDialog> createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<_ExerciseSelectionDialog> {
  String _searchQuery = '';
  MuscleCategory? _selectedCategory;

  List<Exercise> get _filteredExercises {
    return widget.exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null ||
          exercise.involvesCategory(_selectedCategory!);
      return matchesSearch && matchesCategory;
    }).toList();
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
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    loc.get('select_exercise'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: loc.get('search_exercises'),
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category filter
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MuscleCategory.values.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(loc.get('all')),
                        selected: _selectedCategory == null,
                        onSelected: (_) => setState(() => _selectedCategory = null),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primaryRed.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryRed,
                      ),
                    );
                  }

                  final category = MuscleCategory.values[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(loc.get(category.localizationKey)),
                      selected: _selectedCategory == category,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primaryRed.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryRed,
                    ),
                  );
                },
              ),
            ),

            const Divider(color: AppColors.border),

            // Exercise list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => Navigator.of(context).pop(exercise),
                      title: Text(
                        exercise.getLocalizedName(loc.currentLanguage),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        loc.get(exercise.primaryMuscle.localizationKey),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryRed,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: AppColors.surfaceLight,
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

// Диалог редактирования упражнения
class _EditExerciseDialog extends StatefulWidget {
  final PlannedExercise plannedExercise;

  const _EditExerciseDialog({
    Key? key,
    required this.plannedExercise,
  }) : super(key: key);

  @override
  State<_EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<_EditExerciseDialog> {
  late List<PlannedSet> _sets;
  late TextEditingController _notesController;
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;
  late List<TextEditingController> _restControllers;

  @override
  void initState() {
    super.initState();
    _sets = widget.plannedExercise.plannedSets.map((s) => PlannedSet(
      targetReps: s.targetReps,
      targetWeight: s.targetWeight,
      restSeconds: s.restSeconds,
    )).toList();
    _notesController = TextEditingController(text: widget.plannedExercise.notes ?? '');

    // Initialize controllers for each set
    _weightControllers = _sets.map((set) =>
        TextEditingController(text: set.targetWeight?.toString() ?? '')
    ).toList();
    _repsControllers = _sets.map((set) =>
        TextEditingController(text: set.targetReps.toString())
    ).toList();
    _restControllers = _sets.map((set) =>
        TextEditingController(text: set.restSeconds.toString())
    ).toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _restControllers) {
      controller.dispose();
    }
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
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plannedExercise.exercise.getLocalizedName(loc.currentLanguage),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Sets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.currentLanguage == 'ru' ? 'ПОДХОДЫ' : 'SETS',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primaryRed),
                    onPressed: _addSet,
                  ),
                ],
              ),

              ..._sets.asMap().entries.map((entry) => _buildSetRow(entry.key, entry.value, loc)).toList(),

              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: _notesController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: loc.currentLanguage == 'ru' ? 'Заметки' : 'Notes',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Actions
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
                      onPressed: _save,
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

  Widget _buildSetRow(int index, PlannedSet set, LocalizationService loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Weight
          Expanded(
            child: Container(
              height: 40,
              child: TextField(
                controller: _weightControllers[index],
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: loc.currentLanguage == 'ru' ? 'Вес' : 'Weight',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  suffixText: loc.currentLanguage == 'ru' ? 'кг' : 'kg',
                  suffixStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  final weight = double.tryParse(value);
                  setState(() {
                    _sets[index] = _sets[index].copyWith(targetWeight: weight);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reps
          Expanded(
            child: Container(
              height: 40,
              child: TextField(
                controller: _repsControllers[index],
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: loc.currentLanguage == 'ru' ? 'Повт' : 'Reps',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  final reps = int.tryParse(value) ?? 0;
                  setState(() {
                    _sets[index] = _sets[index].copyWith(targetReps: reps);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Rest
          Expanded(
            child: Container(
              height: 40,
              child: TextField(
                controller: _restControllers[index],
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: loc.currentLanguage == 'ru' ? 'Отдых' : 'Rest',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  suffixText: loc.currentLanguage == 'ru' ? 'сек' : 's',
                  suffixStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  final rest = int.tryParse(value) ?? 90;
                  setState(() {
                    _sets[index] = _sets[index].copyWith(restSeconds: rest);
                  });
                },
              ),
            ),
          ),

          // Delete button
          if (_sets.length > 1)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.warning, size: 20),
              onPressed: () => setState(() {
                _sets.removeAt(index);
                _weightControllers[index].dispose();
                _weightControllers.removeAt(index);
                _repsControllers[index].dispose();
                _repsControllers.removeAt(index);
                _restControllers[index].dispose();
                _restControllers.removeAt(index);
              }),
            ),
        ],
      ),
    );
  }

  void _addSet() {
    setState(() {
      final newSet = PlannedSet(
        targetReps: 10,
        targetWeight: _sets.isNotEmpty ? _sets.last.targetWeight : null,
        restSeconds: 90,
      );
      _sets.add(newSet);
      _weightControllers.add(TextEditingController(text: newSet.targetWeight?.toString() ?? ''));
      _repsControllers.add(TextEditingController(text: newSet.targetReps.toString()));
      _restControllers.add(TextEditingController(text: newSet.restSeconds.toString()));
    });
  }

  void _save() {
    final result = PlannedExercise(
      exercise: widget.plannedExercise.exercise,
      plannedSets: _sets,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }
}