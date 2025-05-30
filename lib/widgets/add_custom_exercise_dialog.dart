// lib/widgets/add_custom_exercise_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../services/localization_service.dart';
import '../widgets/custom_widgets.dart';

class AddCustomExerciseDialog extends StatefulWidget {
  final Function(Exercise) onAdd;

  const AddCustomExerciseDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddCustomExerciseDialog> createState() => _AddCustomExerciseDialogState();
}

class _AddCustomExerciseDialogState extends State<AddCustomExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  MuscleCategory _selectedCategory = MuscleCategory.chest;
  DetailedMuscle? _selectedPrimaryMuscle;
  final List<DetailedMuscle> _selectedSecondaryMuscles = [];

  @override
  void initState() {
    super.initState();
    // Set initial primary muscle based on category
    _updateAvailableMuscles();
  }

  void _updateAvailableMuscles() {
    final availableMuscles = _getMusclesForCategory(_selectedCategory);
    if (availableMuscles.isNotEmpty && !availableMuscles.contains(_selectedPrimaryMuscle)) {
      _selectedPrimaryMuscle = availableMuscles.first;
    }

    // Remove secondary muscles that are not in the selected category
    _selectedSecondaryMuscles.removeWhere((muscle) => muscle.category != _selectedCategory);
  }

  List<DetailedMuscle> _getMusclesForCategory(MuscleCategory category) {
    return DetailedMuscle.values.where((muscle) => muscle.category == category).toList();
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryRed, AppColors.darkRed],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        loc.get('add_custom_exercise'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Exercise Name
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: loc.get('exercise_name'),
                    hintText: loc.currentLanguage == 'ru'
                        ? 'например, Кроссовер'
                        : 'e.g. Cable Crossover',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.fitness_center,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.warning),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.warning, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.get('please_enter_exercise_name');
                    }
                    if (value.trim().length < 3) {
                      return loc.get('name_must_be_3_chars');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Muscle Category Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.get('muscle_category'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MuscleCategory>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryRed,
                          ),
                          items: MuscleCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(loc.get(category.localizationKey)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                                _updateAvailableMuscles();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Primary Muscle Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.get('primary_muscle_group'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DetailedMuscle>(
                          value: _selectedPrimaryMuscle,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primaryRed,
                          ),
                          items: _getMusclesForCategory(_selectedCategory).map((muscle) {
                            return DropdownMenuItem(
                              value: muscle,
                              child: Text(loc.get(muscle.localizationKey)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPrimaryMuscle = value;
                                // Remove from secondary if selected as primary
                                _selectedSecondaryMuscles.remove(value);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Secondary Muscles Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.get('secondary_muscle_groups'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.currentLanguage == 'ru'
                                ? 'Мышцы из категории ${loc.get(_selectedCategory.localizationKey)}:'
                                : 'Muscles from ${loc.get(_selectedCategory.localizationKey)} category:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _getMusclesForCategory(_selectedCategory)
                                .where((muscle) => muscle != _selectedPrimaryMuscle)
                                .map((muscle) => _buildMuscleChip(muscle, loc))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 12),
                          Text(
                            loc.currentLanguage == 'ru'
                                ? 'Мышцы из других категорий:'
                                : 'Muscles from other categories:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...MuscleCategory.values
                              .where((cat) => cat != _selectedCategory)
                              .map((category) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  loc.get(category.localizationKey),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _getMusclesForCategory(category)
                                    .map((muscle) => _buildMuscleChip(muscle, loc))
                                    .toList(),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: loc.get('brief_description'),
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.description,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryRed.withOpacity(0.1),
                        AppColors.darkRed.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.get('custom_exercises_saved'),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        text: loc.get('save_exercise'),
                        icon: Icons.save,
                        onPressed: _saveExercise,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleChip(DetailedMuscle muscle, LocalizationService loc) {
    final isSelected = _selectedSecondaryMuscles.contains(muscle);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSecondaryMuscles.remove(muscle);
          } else {
            _selectedSecondaryMuscles.add(muscle);
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withOpacity(0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                size: 14,
                color: AppColors.primaryRed,
              ),
            if (isSelected)
              const SizedBox(width: 4),
            Flexible(
              child: Text(
                loc.get(muscle.localizationKey),
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryRed
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
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

  void _saveExercise() {
    if (_formKey.currentState!.validate() && _selectedPrimaryMuscle != null) {
      final exercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        primaryMuscle: _selectedPrimaryMuscle!,
        secondaryMuscles: _selectedSecondaryMuscles,
        description: _descriptionController.text.trim().isEmpty
            ? 'Custom exercise'
            : _descriptionController.text.trim(),
      );

      widget.onAdd(exercise);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}