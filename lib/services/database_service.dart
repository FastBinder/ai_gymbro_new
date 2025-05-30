// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gymbro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Увеличиваем версию для миграции
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create exercises table with new structure
    await db.execute('''
      CREATE TABLE exercises(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        primaryMuscle TEXT NOT NULL,
        secondaryMuscles TEXT,
        description TEXT NOT NULL,
        imageUrl TEXT,
        videoUrl TEXT,
        instructions TEXT,
        tips TEXT,
        isCustom INTEGER DEFAULT 0
      )
    ''');

    // Create workouts table
    await db.execute('''
      CREATE TABLE workouts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    // Create workout_exercises table (many-to-many relationship)
    await db.execute('''
      CREATE TABLE workout_exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        orderIndex INTEGER NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id)
      )
    ''');

    // Create sets table
    await db.execute('''
      CREATE TABLE sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutExerciseId INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (workoutExerciseId) REFERENCES workout_exercises (id) ON DELETE CASCADE
      )
    ''');

    // Insert default exercises
    await _insertDefaultExercises(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Миграция на версию 3 с новой системой мышц
      await db.transaction((txn) async {
        // Создаем временную таблицу с новой структурой
        await txn.execute('''
        CREATE TABLE exercises_new(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          primaryMuscle TEXT NOT NULL,
          secondaryMuscles TEXT,
          description TEXT NOT NULL,
          imageUrl TEXT,
          videoUrl TEXT,
          instructions TEXT,
          tips TEXT,
          isCustom INTEGER DEFAULT 0
        )
      ''');

        // Копируем данные из старой таблицы с миграцией
        final exercises = await txn.query('exercises');
        for (final exercise in exercises) {
          // Мапим старые мышцы на новые
          String oldPrimary = exercise['primaryMuscle'] as String;
          String newPrimary = _mapOldMuscleToDetailedMuscle(oldPrimary);

          // Обрабатываем secondaryMuscles
          String? oldSecondary = exercise['secondaryMuscles'] as String?;
          String newSecondary = '';
          if (oldSecondary != null && oldSecondary.isNotEmpty) {
            final muscles = oldSecondary.split('|');
            final mappedMuscles = muscles
                .map((m) => _mapOldMuscleToDetailedMuscle(m))
                .where((m) => m.isNotEmpty)
                .toList();
            newSecondary = mappedMuscles.join('|');
          }

          await txn.insert('exercises_new', {
            'id': exercise['id'],
            'name': exercise['name'],
            'primaryMuscle': newPrimary,
            'secondaryMuscles': newSecondary,
            'description': exercise['description'],
            'imageUrl': exercise['imageUrl'],
            'videoUrl': exercise['videoUrl'],
            'instructions': exercise['instructions'],
            'tips': exercise['tips'],
            'isCustom': exercise['isCustom'] ?? 0,
          });
        }

        // Удаляем старую таблицу и переименовываем новую
        await txn.execute('DROP TABLE exercises');
        await txn.execute('ALTER TABLE exercises_new RENAME TO exercises');
      });
    }
  }

  String _mapOldMuscleToDetailedMuscle(String oldMuscle) {
    // Используем миграционную карту из Exercise модели
    final migrationMap = {
      'chest': 'middleChest',
      'back': 'lats',
      'shoulders': 'frontDelts',
      'biceps': 'biceps',
      'triceps': 'longHeadTriceps',
      'forearms': 'forearms',
      'abs': 'abs',
      'obliques': 'obliques',
      'quadriceps': 'quadriceps',
      'hamstrings': 'hamstrings',
      'glutes': 'glutes',
      'calves': 'calves',
      'traps': 'upperTraps',
      'lats': 'lats',
      'middleBack': 'rhomboids',
      'lowerBack': 'lowerBack',
      'frontDelts': 'frontDelts',
      'sideDelts': 'sideDelts',
      'rearDelts': 'rearDelts',
      'middle_back': 'rhomboids',
      'lower_back': 'lowerBack',
      'front_delts': 'frontDelts',
      'side_delts': 'sideDelts',
      'rear_delts': 'rearDelts',
    };

    return migrationMap[oldMuscle] ?? 'middleChest';
  }

  Future<void> _insertDefaultExercises(Database db) async {
    for (var exercise in ExerciseDatabase.exercises) {
      await db.insert('exercises', {
        ...exercise.toMap(),
        'isCustom': 0,
      });
    }
  }

  // Exercise methods
  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final result = await db.query('exercises', orderBy: 'primaryMuscle, name');
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<Exercise?> getExercise(String id) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<String> createCustomExercise(Exercise exercise) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final customExercise = Exercise(
      id: id,
      name: exercise.name,
      primaryMuscle: exercise.primaryMuscle,
      secondaryMuscles: exercise.secondaryMuscles,
      description: exercise.description,
      instructions: exercise.instructions,
      tips: exercise.tips,
    );

    await db.insert('exercises', {
      ...customExercise.toMap(),
      'isCustom': 1,
    });

    return id;
  }

  Future<void> deleteExercise(String id) async {
    final db = await database;

    // Check if exercise is used in any workouts
    final usageCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM workout_exercises WHERE exerciseId = ?',
        [id],
      ),
    ) ?? 0;

    if (usageCount > 0) {
      throw Exception('Cannot delete exercise that is used in workouts');
    }

    // Delete only if it's a custom exercise
    final result = await db.delete(
      'exercises',
      where: 'id = ? AND isCustom = 1',
      whereArgs: [id],
    );

    if (result == 0) {
      throw Exception('Cannot delete built-in exercises');
    }
  }

  // Workout methods
  Future<String> createWorkout(Workout workout) async {
    final db = await database;

    // Start transaction
    await db.transaction((txn) async {
      // Insert workout
      await txn.insert('workouts', {
        'id': workout.id,
        'name': workout.name,
        'date': workout.date.toIso8601String(),
        'duration': workout.duration.inSeconds,
      });

      // Insert workout exercises and sets
      for (int i = 0; i < workout.exercises.length; i++) {
        final workoutExercise = workout.exercises[i];

        // Insert workout_exercise
        final workoutExerciseId = await txn.insert('workout_exercises', {
          'workoutId': workout.id,
          'exerciseId': workoutExercise.exercise.id,
          'orderIndex': i,
        });

        // Insert sets
        for (final set in workoutExercise.sets) {
          await txn.insert('sets', {
            'workoutExerciseId': workoutExerciseId,
            'reps': set.reps,
            'weight': set.weight,
            'timestamp': set.timestamp.toIso8601String(),
          });
        }
      }
    });

    return workout.id;
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;

    // Get all workouts
    final workoutMaps = await db.query(
      'workouts',
      orderBy: 'date DESC',
    );

    List<Workout> workouts = [];

    for (final workoutMap in workoutMaps) {
      // Get workout exercises
      final workoutExerciseMaps = await db.query(
        'workout_exercises',
        where: 'workoutId = ?',
        whereArgs: [workoutMap['id']],
        orderBy: 'orderIndex',
      );

      List<WorkoutExercise> exercises = [];

      for (final weMap in workoutExerciseMaps) {
        // Get exercise details
        final exerciseMaps = await db.query(
          'exercises',
          where: 'id = ?',
          whereArgs: [weMap['exerciseId']],
        );

        if (exerciseMaps.isEmpty) continue;

        final exercise = Exercise.fromMap(exerciseMaps.first);

        // Get sets
        final setMaps = await db.query(
          'sets',
          where: 'workoutExerciseId = ?',
          whereArgs: [weMap['id']],
          orderBy: 'timestamp',
        );

        final sets = setMaps.map((setMap) => WorkoutSet(
          reps: setMap['reps'] as int,
          weight: setMap['weight'] as double,
          timestamp: DateTime.parse(setMap['timestamp'] as String),
        )).toList();

        exercises.add(WorkoutExercise(
          exercise: exercise,
          sets: sets,
        ));
      }

      workouts.add(Workout(
        id: workoutMap['id'] as String,
        name: workoutMap['name'] as String,
        date: DateTime.parse(workoutMap['date'] as String),
        exercises: exercises,
        duration: Duration(seconds: workoutMap['duration'] as int),
      ));
    }

    return workouts;
  }

  Future<void> deleteWorkout(String id) async {
    final db = await database;
    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics methods
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    // Total workouts
    final totalWorkouts = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM workouts')
    ) ?? 0;

    // Total duration
    final totalSeconds = Sqflite.firstIntValue(
        await db.rawQuery('SELECT SUM(duration) FROM workouts')
    ) ?? 0;

    // Current streak
    final streak = await _calculateStreak();

    return {
      'totalWorkouts': totalWorkouts,
      'totalDuration': Duration(seconds: totalSeconds),
      'currentStreak': streak,
    };
  }

  Future<int> _calculateStreak() async {
    final db = await database;
    final workouts = await db.query(
      'workouts',
      columns: ['date'],
      orderBy: 'date DESC',
    );

    if (workouts.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final workout in workouts) {
      final date = DateTime.parse(workout['date'] as String);
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (lastDate == null) {
        // First workout
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        if (dateOnly == todayOnly ||
            dateOnly == todayOnly.subtract(const Duration(days: 1))) {
          streak = 1;
          lastDate = dateOnly;
        } else {
          break;
        }
      } else {
        // Check if consecutive
        if (dateOnly == lastDate.subtract(const Duration(days: 1))) {
          streak++;
          lastDate = dateOnly;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}