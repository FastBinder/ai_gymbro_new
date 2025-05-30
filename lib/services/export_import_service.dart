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
        'version': 3, // Увеличиваем версию для новой структуры
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
        if (version >= 3) {
          // Новая версия с DetailedMuscle
          exercise = Exercise(
            id: e['exerciseId'],
            name: e['exerciseName'],
            primaryMuscle: DetailedMuscle.fromString(e['exercisePrimaryMuscle']),
            secondaryMuscles: (e['exerciseSecondaryMuscles'] as List?)
                ?.map((m) => DetailedMuscle.fromString(m))
                .toList() ?? [],
            description: e['exerciseDescription'],
          );
        } else if (version == 2) {
          // Версия 2 с MuscleGroup
          exercise = Exercise(
            id: e['exerciseId'],
            name: e['exerciseName'],
            primaryMuscle: _mapOldMuscleGroupToDetailedMuscle(e['exercisePrimaryMuscle']),
            secondaryMuscles: (e['exerciseSecondaryMuscles'] as List?)
                ?.map((m) => _mapOldMuscleGroupToDetailedMuscle(m))
                .toList() ?? [],
            description: e['exerciseDescription'],
          );
        } else {
          // Старая версия 1
          exercise = Exercise(
            id: e['exerciseId'],
            name: e['exerciseName'],
            primaryMuscle: _mapOldMuscleGroupToDetailedMuscle(e['exerciseMuscleGroup']),
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
    if (version >= 3) {
      // Новая версия с DetailedMuscle
      return Exercise(
        id: json['id'],
        name: json['name'],
        primaryMuscle: DetailedMuscle.fromString(json['primaryMuscle']),
        secondaryMuscles: (json['secondaryMuscles'] as List?)
            ?.map((m) => DetailedMuscle.fromString(m))
            .toList() ?? [],
        description: json['description'],
        instructions: json['instructions'] != null
            ? List<String>.from(json['instructions'])
            : null,
        tips: json['tips'] != null
            ? List<String>.from(json['tips'])
            : null,
      );
    } else if (version == 2) {
      // Версия 2 с MuscleGroup
      return Exercise(
        id: json['id'],
        name: json['name'],
        primaryMuscle: _mapOldMuscleGroupToDetailedMuscle(json['primaryMuscle']),
        secondaryMuscles: (json['secondaryMuscles'] as List?)
            ?.map((m) => _mapOldMuscleGroupToDetailedMuscle(m))
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
      // Старая версия 1
      return Exercise(
        id: json['id'],
        name: json['name'],
        primaryMuscle: _mapOldMuscleGroupToDetailedMuscle(json['muscleGroup']),
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
  static DetailedMuscle _mapOldMuscleGroupToDetailedMuscle(String oldMuscleGroup) {
    final mapping = {
      // Версия 1 (старые категории)
      'Chest': DetailedMuscle.middleChest,
      'Back': DetailedMuscle.lats,
      'Legs': DetailedMuscle.quadriceps,
      'Shoulders': DetailedMuscle.frontDelts,
      'Arms': DetailedMuscle.biceps,
      'Core': DetailedMuscle.abs,
      'Full Body': DetailedMuscle.middleChest,
      'Cardio': DetailedMuscle.abs,
      'Other': DetailedMuscle.middleChest,

      // Версия 2 (MuscleGroup enum)
      'chest': DetailedMuscle.middleChest,
      'back': DetailedMuscle.lats,
      'shoulders': DetailedMuscle.frontDelts,
      'biceps': DetailedMuscle.biceps,
      'triceps': DetailedMuscle.longHeadTriceps,
      'forearms': DetailedMuscle.forearms,
      'abs': DetailedMuscle.abs,
      'obliques': DetailedMuscle.obliques,
      'quadriceps': DetailedMuscle.quadriceps,
      'hamstrings': DetailedMuscle.hamstrings,
      'glutes': DetailedMuscle.glutes,
      'calves': DetailedMuscle.calves,
      'traps': DetailedMuscle.upperTraps,
      'lats': DetailedMuscle.lats,
      'middleBack': DetailedMuscle.rhomboids,
      'lowerBack': DetailedMuscle.lowerBack,
      'frontDelts': DetailedMuscle.frontDelts,
      'sideDelts': DetailedMuscle.sideDelts,
      'rearDelts': DetailedMuscle.rearDelts,
    };

    return mapping[oldMuscleGroup] ?? DetailedMuscle.middleChest;
  }


  // Получить размер данных
  static Future<String> getDataSize() async {
    final workouts = await _db.getAllWorkouts();
    final exercises = await _db.getAllExercises();
    final customExercises = exercises.where((e) => e.id.length > 10).length;

    return '${workouts.length} workouts, $customExercises custom exercises';
  }
}