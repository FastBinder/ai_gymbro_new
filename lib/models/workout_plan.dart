// lib/models/workout_plan.dart

import 'exercise.dart';
import 'workout.dart';

/// Запланированный подход
class PlannedSet {
  final int targetReps;
  final double? targetWeight; // null если вес еще не определен
  final int restSeconds; // время отдыха после подхода

  PlannedSet({
    required this.targetReps,
    this.targetWeight,
    this.restSeconds = 90,
  });

  Map<String, dynamic> toMap() {
    return {
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'restSeconds': restSeconds,
    };
  }

  factory PlannedSet.fromMap(Map<String, dynamic> map) {
    return PlannedSet(
      targetReps: map['targetReps'],
      targetWeight: map['targetWeight']?.toDouble(),
      restSeconds: map['restSeconds'] ?? 90,
    );
  }

  PlannedSet copyWith({
    int? targetReps,
    double? targetWeight,
    int? restSeconds,
  }) {
    return PlannedSet(
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

/// Запланированное упражнение
class PlannedExercise {
  final Exercise exercise;
  final List<PlannedSet> plannedSets;
  final String? notes; // заметки к упражнению

  PlannedExercise({
    required this.exercise,
    required this.plannedSets,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exercise.id,
      'plannedSets': plannedSets.map((s) => s.toMap()).toList(),
      'notes': notes,
    };
  }

  PlannedExercise copyWith({
    Exercise? exercise,
    List<PlannedSet>? plannedSets,
    String? notes,
  }) {
    return PlannedExercise(
      exercise: exercise ?? this.exercise,
      plannedSets: plannedSets ?? this.plannedSets,
      notes: notes ?? this.notes,
    );
  }
}

/// План тренировки
class WorkoutPlan {
  final String id;
  final String name;
  final String? description;
  final List<PlannedExercise> exercises;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final int timesUsed;
  final WorkoutPlanType type;
  final List<String> tags; // например: ["Push", "Upper Body", "Strength"]

  WorkoutPlan({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    required this.createdAt,
    this.lastUsedAt,
    this.timesUsed = 0,
    this.type = WorkoutPlanType.custom,
    this.tags = const [],
  });

  /// Примерная продолжительность тренировки в минутах
  int get estimatedDuration {
    int totalSeconds = 0;

    // Время на подходы (примерно 30 секунд на подход)
    for (var exercise in exercises) {
      totalSeconds += exercise.plannedSets.length * 30;

      // Время отдыха между подходами
      for (var set in exercise.plannedSets) {
        totalSeconds += set.restSeconds;
      }
    }

    // Время на переход между упражнениями (2 минуты)
    totalSeconds += (exercises.length - 1) * 120;

    return (totalSeconds / 60).ceil();
  }

  /// Общее количество подходов
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.plannedSets.length);
  }

  /// Основные группы мышц
  Set<MuscleCategory> get targetMuscles {
    final muscles = <MuscleCategory>{};
    for (var exercise in exercises) {
      muscles.addAll(exercise.exercise.involvedCategories);
    }
    return muscles;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'timesUsed': timesUsed,
      'type': type.index,
      'tags': tags,
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map, List<Exercise> availableExercises) {
    final exercises = <PlannedExercise>[];

    for (var exerciseData in map['exercises']) {
      final exercise = availableExercises.firstWhere(
            (e) => e.id == exerciseData['exerciseId'],
        orElse: () => throw Exception('Exercise not found: ${exerciseData['exerciseId']}'),
      );

      final plannedSets = (exerciseData['plannedSets'] as List)
          .map((s) => PlannedSet.fromMap(s))
          .toList();

      exercises.add(PlannedExercise(
        exercise: exercise,
        plannedSets: plannedSets,
        notes: exerciseData['notes'],
      ));
    }

    return WorkoutPlan(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      exercises: exercises,
      createdAt: DateTime.parse(map['createdAt']),
      lastUsedAt: map['lastUsedAt'] != null ? DateTime.parse(map['lastUsedAt']) : null,
      timesUsed: map['timesUsed'] ?? 0,
      type: WorkoutPlanType.values[map['type'] ?? 0],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? description,
    List<PlannedExercise>? exercises,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? timesUsed,
    WorkoutPlanType? type,
    List<String>? tags,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      timesUsed: timesUsed ?? this.timesUsed,
      type: type ?? this.type,
      tags: tags ?? this.tags,
    );
  }
}

/// Типы планов тренировок
enum WorkoutPlanType {
  custom, // Пользовательский план
  template, // Шаблон
  program, // Часть программы тренировок
}

/// Предустановленные шаблоны тренировок
class WorkoutTemplates {
  static WorkoutPlan pushDay() {
    return WorkoutPlan(
      id: 'template_push',
      name: 'Push Day',
      description: 'Chest, Shoulders, Triceps',
      exercises: [
        PlannedExercise(
          exercise: Exercise(
            id: '1',
            name: 'Barbell Bench Press',
            primaryMuscle: DetailedMuscle.middleChest,
            secondaryMuscles: [DetailedMuscle.frontDelts, DetailedMuscle.medialHeadTriceps],
            description: 'Primary chest exercise',
          ),
          plannedSets: [
            PlannedSet(targetReps: 12, restSeconds: 60),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 8, restSeconds: 120),
            PlannedSet(targetReps: 8, restSeconds: 120),
          ],
          notes: 'Warm up properly before working sets',
        ),
        PlannedExercise(
          exercise: Exercise(
            id: '23',
            name: 'Dumbbell Shoulder Press',
            primaryMuscle: DetailedMuscle.frontDelts,
            secondaryMuscles: [DetailedMuscle.sideDelts, DetailedMuscle.medialHeadTriceps],
            description: 'Overhead pressing movement',
          ),
          plannedSets: [
            PlannedSet(targetReps: 12, restSeconds: 60),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
          ],
        ),
        PlannedExercise(
          exercise: Exercise(
            id: '24',
            name: 'Dumbbell Lateral Raises',
            primaryMuscle: DetailedMuscle.sideDelts,
            secondaryMuscles: [],
            description: 'Isolation for side delts',
          ),
          plannedSets: [
            PlannedSet(targetReps: 15, restSeconds: 45),
            PlannedSet(targetReps: 15, restSeconds: 45),
            PlannedSet(targetReps: 12, restSeconds: 45),
          ],
        ),
      ],
      createdAt: DateTime.now(),
      type: WorkoutPlanType.template,
      tags: ['Push', 'Upper Body'],
    );
  }

  static WorkoutPlan pullDay() {
    return WorkoutPlan(
      id: 'template_pull',
      name: 'Pull Day',
      description: 'Back and Biceps',
      exercises: [
        PlannedExercise(
          exercise: Exercise(
            id: '36',
            name: 'Lat Pulldown',
            primaryMuscle: DetailedMuscle.lats,
            secondaryMuscles: [DetailedMuscle.rhomboids, DetailedMuscle.biceps],
            description: 'Primary lat exercise',
          ),
          plannedSets: [
            PlannedSet(targetReps: 12, restSeconds: 60),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 8, restSeconds: 90),
          ],
        ),
        PlannedExercise(
          exercise: Exercise(
            id: '4',
            name: 'Barbell Bent-Over Row',
            primaryMuscle: DetailedMuscle.lats,
            secondaryMuscles: [DetailedMuscle.rhomboids, DetailedMuscle.middleTraps],
            description: 'Compound back movement',
          ),
          plannedSets: [
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 8, restSeconds: 120),
          ],
        ),
      ],
      createdAt: DateTime.now(),
      type: WorkoutPlanType.template,
      tags: ['Pull', 'Upper Body'],
    );
  }

  static WorkoutPlan legDay() {
    return WorkoutPlan(
      id: 'template_legs',
      name: 'Leg Day',
      description: 'Quadriceps, Hamstrings, Glutes',
      exercises: [
        PlannedExercise(
          exercise: Exercise(
            id: '2',
            name: 'Barbell Back Squat',
            primaryMuscle: DetailedMuscle.quadriceps,
            secondaryMuscles: [DetailedMuscle.glutes, DetailedMuscle.hamstrings],
            description: 'Primary leg exercise',
          ),
          plannedSets: [
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 8, restSeconds: 120),
            PlannedSet(targetReps: 8, restSeconds: 120),
            PlannedSet(targetReps: 6, restSeconds: 180),
          ],
          notes: 'Focus on depth and form',
        ),
        PlannedExercise(
          exercise: Exercise(
            id: '27',
            name: 'Romanian Deadlift',
            primaryMuscle: DetailedMuscle.hamstrings,
            secondaryMuscles: [DetailedMuscle.glutes, DetailedMuscle.erectorSpinae],
            description: 'Hip hinge movement',
          ),
          plannedSets: [
            PlannedSet(targetReps: 12, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
            PlannedSet(targetReps: 10, restSeconds: 90),
          ],
        ),
      ],
      createdAt: DateTime.now(),
      type: WorkoutPlanType.template,
      tags: ['Legs', 'Lower Body'],
    );
  }
}