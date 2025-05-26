// lib/services/export_import_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import 'database_service.dart';

class ExportImportService {
  static final DatabaseService _db = DatabaseService.instance;

  // Экспорт всех данных в JSON
  static Future<String> exportData() async {
    try {
      // Получаем все данные
      final workouts = await _db.getAllWorkouts();
      final exercises = await _db.getAllExercises();

      // Фильтруем только кастомные упражнения
      final customExercises = exercises.where((e) => e.id.length > 10).toList();

      // Создаем JSON структуру
      final exportData = {
        'version': 2, // Увеличиваем версию для новой структуры
        'exportDate': DateTime.now().toIso8601String(),
        'workouts': workouts.map((w) => _workoutToJson(w)).toList(),
        'customExercises': customExercises.map((e) => _exerciseToJson(e)).toList(),
      };

      // Конвертируем в JSON строку
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Сохраняем в файл
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/gym_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  // Импорт данных из JSON
  static Future<void> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);

      // Проверяем версию
      final version = data['version'] ?? 1;

      // Импортируем кастомные упражнения
      if (data['customExercises'] != null) {
        for (var exerciseJson in data['customExercises']) {
          final exercise = _exerciseFromJson(exerciseJson, version);
          // Проверяем, существует ли уже
          final existing = await _db.getAllExercises();
          if (!existing.any((e) => e.id == exercise.id)) {
            await _db.createCustomExercise(exercise);
          }
        }
      }

      // Импортируем тренировки
      if (data['workouts'] != null) {
        for (var workoutJson in data['workouts']) {
          final workout = await _workoutFromJson(workoutJson, version);
          // Проверяем, существует ли уже
          final existing = await _db.getAllWorkouts();
          if (!existing.any((w) => w.id == workout.id)) {
            await _db.createWorkout(workout);
          }
        }
      }
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  // Конвертация Workout в JSON
  static Map<String, dynamic> _workoutToJson(Workout workout) {
    return {
      'id': workout.id,
      'name': workout.name,
      'date': workout.date.toIso8601String(),
      'duration': workout.duration.inSeconds,
      'exercises': workout.exercises.map((e) => {
        'exerciseId': e.exercise.id,
        'exerciseName': e.exercise.name,
        'exercisePrimaryMuscle': e.exercise.primaryMuscle.name,
        'exerciseSecondaryMuscles': e.exercise.secondaryMuscles.map((m) => m.name).toList(),
        'exerciseDescription': e.exercise.description,
        'sets': e.sets.map((s) => {
          'weight': s.weight,
          'reps': s.reps,
          'timestamp': s.timestamp.toIso8601String(),
        }).toList(),
      }).toList(),
    };
  }

  // Конвертация JSON в Workout
  static Future<Workout> _workoutFromJson(Map<String, dynamic> json, int version) async {
    final exercisesList = <WorkoutExercise>[];

    for (var e in json['exercises']) {
      Exercise? exercise;

      // Сначала пытаемся найти упражнение в БД
      if (e['exerciseId'] != null) {
        exercise = await _db.getExercise(e['exerciseId']);
      }

      // Если не нашли, создаем из данных в JSON
      if (exercise == null) {
        if (version == 2) {
          // Новая версия с primaryMuscle и secondaryMuscles
          exercise = Exercise(
            id: e['exerciseId'],
            name: e['exerciseName'],
            primaryMuscle: MuscleGroup.fromString(e['exercisePrimaryMuscle']),
            secondaryMuscles: (e['exerciseSecondaryMuscles'] as List?)
                ?.map((m) => MuscleGroup.fromString(m))
                .toList() ?? [],
            description: e['exerciseDescription'],
          );
        } else {
          // Старая версия с muscleGroup
          exercise = Exercise(
            id: e['exerciseId'],
            name: e['exerciseName'],
            primaryMuscle: _mapOldMuscleGroupToEnum(e['exerciseMuscleGroup']),
            secondaryMuscles: [],
            description: e['exerciseDescription'],
          );
        }
      }

      exercisesList.add(WorkoutExercise(
        exercise: exercise,
        sets: (e['sets'] as List).map((s) => WorkoutSet(
          weight: s['weight'].toDouble(),
          reps: s['reps'],
          timestamp: DateTime.parse(s['timestamp']),
        )).toList(),
      ));
    }

    return Workout(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration']),
      exercises: exercisesList,
    );
  }

  // Конвертация Exercise в JSON
  static Map<String, dynamic> _exerciseToJson(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'primaryMuscle': exercise.primaryMuscle.name,
      'secondaryMuscles': exercise.secondaryMuscles.map((m) => m.name).toList(),
      'description': exercise.description,
      'instructions': exercise.instructions,
      'tips': exercise.tips,
    };
  }

  // Конвертация JSON в Exercise
  static Exercise _exerciseFromJson(Map<String, dynamic> json, int version) {
    if (version == 2) {
      // Новая версия с primaryMuscle и secondaryMuscles
      return Exercise(
        id: json['id'],
        name: json['name'],
        primaryMuscle: MuscleGroup.fromString(json['primaryMuscle']),
        secondaryMuscles: (json['secondaryMuscles'] as List?)
            ?.map((m) => MuscleGroup.fromString(m))
            .toList() ?? [],
        description: json['description'],
        instructions: json['instructions'] != null
            ? List<String>.from(json['instructions'])
            : null,
        tips: json['tips'] != null
            ? List<String>.from(json['tips'])
            : null,
      );
    } else {
      // Старая версия с muscleGroup
      return Exercise(
        id: json['id'],
        name: json['name'],
        primaryMuscle: _mapOldMuscleGroupToEnum(json['muscleGroup']),
        secondaryMuscles: [],
        description: json['description'],
        instructions: json['instructions'] != null
            ? List<String>.from(json['instructions'])
            : null,
        tips: json['tips'] != null
            ? List<String>.from(json['tips'])
            : null,
      );
    }
  }

  // Мапинг старых групп мышц на новые
  static MuscleGroup _mapOldMuscleGroupToEnum(String oldMuscleGroup) {
    final mapping = {
      'Chest': MuscleGroup.chest,
      'Back': MuscleGroup.back,
      'Legs': MuscleGroup.quadriceps,
      'Shoulders': MuscleGroup.shoulders,
      'Arms': MuscleGroup.biceps,
      'Core': MuscleGroup.abs,
      'Full Body': MuscleGroup.chest,
      'Cardio': MuscleGroup.abs,
      'Other': MuscleGroup.chest,
    };

    return mapping[oldMuscleGroup] ?? MuscleGroup.chest;
  }

  // Получить размер данных
  static Future<String> getDataSize() async {
    final workouts = await _db.getAllWorkouts();
    final exercises = await _db.getAllExercises();
    final customExercises = exercises.where((e) => e.id.length > 10).length;

    return '${workouts.length} workouts, $customExercises custom exercises';
  }
}