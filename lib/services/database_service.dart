// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/exercise.dart';
import '../models/workout.dart';

class DatabaseService {
  static Database? _database;
  static Database? _exercisesDb;
  static final DatabaseService instance = DatabaseService._init();

  // Кеш для упражнений
  final Map<int, List<Exercise>> _categoryCache = {};
  final Map<String, Exercise> _exerciseCache = {};
  List<Exercise>? _allExercisesCache;

  DatabaseService._init();

  // Constants
  static const String MAIN_DB = 'gymbro.db';
  static const String EXERCISES_DB = 'exercises.db';
  static const int EXERCISES_DB_VERSION = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(MAIN_DB);
    return _database!;
  }

  Future<Database> get exercisesDb async {
    if (_exercisesDb != null) return _exercisesDb!;
    _exercisesDb = await _initExercisesDB();
    return _exercisesDb!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<Database> _initExercisesDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, EXERCISES_DB);

    // Проверяем, нужно ли обновить БД упражнений
    await _checkAndUpdateExercisesDB(path);

    // Открываем БД упражнений
    return await openDatabase(
      path,
      readOnly: true,
      singleInstance: true,
    );
  }

  Future<void> _checkAndUpdateExercisesDB(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt('exercises_db_version') ?? 0;

    final file = File(path);
    final shouldUpdate = !file.existsSync() || currentVersion < EXERCISES_DB_VERSION;

    if (shouldUpdate) {
      // Загружаем БД из assets
      final data = await rootBundle.load('assets/databases/$EXERCISES_DB');
      final bytes = data.buffer.asUint8List();

      // Создаем директорию если не существует
      final dir = Directory(dirname(path));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      // Записываем файл
      await file.writeAsBytes(bytes, flush: true);

      // Сохраняем версию
      await prefs.setInt('exercises_db_version', EXERCISES_DB_VERSION);

      // Очищаем кеш при обновлении
      _clearCache();
    }
  }

  void _clearCache() {
    _categoryCache.clear();
    _exerciseCache.clear();
    _allExercisesCache = null;
  }

  Future<void> _createDB(Database db, int version) async {
    // Таблица тренировок
    await db.execute('''
      CREATE TABLE workouts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    // Таблица упражнений в тренировке
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

    // Таблица подходов
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

    // Таблица кастомных упражнений
    await db.execute('''
      CREATE TABLE custom_exercises(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        primaryMuscle TEXT NOT NULL,
        secondaryMuscles TEXT,
        description TEXT NOT NULL,
        imageUrl TEXT,
        videoUrl TEXT,
        instructions TEXT,
        tips TEXT
      )
    ''');

    // Индексы для производительности
    await db.execute('CREATE INDEX idx_workout_date ON workouts(date DESC)');
    await db.execute('CREATE INDEX idx_workout_exercises ON workout_exercises(workoutId, orderIndex)');
    await db.execute('CREATE INDEX idx_sets ON sets(workoutExerciseId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Добавляем таблицу кастомных упражнений если её нет
      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_exercises(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          primaryMuscle TEXT NOT NULL,
          secondaryMuscles TEXT,
          description TEXT NOT NULL,
          imageUrl TEXT,
          videoUrl TEXT,
          instructions TEXT,
          tips TEXT
        )
      ''');
    }
  }

  // ============ EXERCISE METHODS ============

  Future<List<Exercise>> getAllExercises() async {
    // Возвращаем из кеша если есть
    if (_allExercisesCache != null) {
      return _allExercisesCache!;
    }

    try {
      // Загружаем упражнения из предзаполненной БД
      final db = await exercisesDb;
      final results = await db.query(
        'exercises',
        orderBy: 'category, name',
      );

      _allExercisesCache = results.map((map) => _parseExercise(map)).toList();

      // Заполняем кеш отдельных упражнений
      for (var exercise in _allExercisesCache!) {
        _exerciseCache[exercise.id] = exercise;
      }

      // Добавляем кастомные упражнения из основной БД
      await _loadCustomExercises();

      return _allExercisesCache!;
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadCustomExercises() async {
    try {
      final mainDb = await database;
      final customExercises = await mainDb.query('custom_exercises');

      for (var map in customExercises) {
        final exercise = Exercise.fromMap(map);
        _allExercisesCache!.add(exercise);
        _exerciseCache[exercise.id] = exercise;
      }
    } catch (e) {
      // Игнорируем ошибки если таблицы нет
    }
  }

  Future<List<Exercise>> getExercisesByCategory(MuscleCategory category) async {
    final categoryIndex = category.index;

    // Проверяем кеш
    if (_categoryCache.containsKey(categoryIndex)) {
      return _categoryCache[categoryIndex]!;
    }

    final allExercises = await getAllExercises();
    final filtered = allExercises.where((e) => e.primaryCategory == category).toList();

    _categoryCache[categoryIndex] = filtered;
    return filtered;
  }

  Future<List<Exercise>> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      return getAllExercises();
    }

    try {
      final db = await exercisesDb;

      // Используем FTS для быстрого поиска
      final results = await db.rawQuery('''
        SELECT e.* FROM exercises e
        JOIN exercises_fts ON e.id = exercises_fts.rowid
        WHERE exercises_fts MATCH ?
        ORDER BY rank
        LIMIT 50
      ''', ['$query*']);

      final exercises = results.map((map) => _parseExercise(map)).toList();

      // Добавляем поиск по кастомным упражнениям
      final mainDb = await database;
      final customResults = await mainDb.query(
        'custom_exercises',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );

      for (var map in customResults) {
        exercises.add(Exercise.fromMap(map));
      }

      return exercises;
    } catch (e) {
      // Fallback на простой поиск
      final allExercises = await getAllExercises();
      return allExercises.where((exercise) =>
          exercise.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  Future<Exercise?> getExercise(String id) async {
    // Проверяем кеш
    if (_exerciseCache.containsKey(id)) {
      return _exerciseCache[id];
    }

    // Для кастомных упражнений (id > 10 символов) ищем в основной БД
    if (id.length > 10) {
      return _getCustomExercise(id);
    }

    try {
      final db = await exercisesDb;
      final maps = await db.query(
        'exercises',
        where: 'id = ?',
        whereArgs: [int.tryParse(id) ?? -1],
      );

      if (maps.isNotEmpty) {
        final exercise = _parseExercise(maps.first);
        _exerciseCache[id] = exercise;
        return exercise;
      }
    } catch (e) {
      // Игнорируем ошибки
    }

    return null;
  }

  Exercise _parseExercise(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      primaryMuscle: DetailedMuscle.values[map['primary_muscle'] ?? 0],
      secondaryMuscles: map['secondary_muscles'] != null &&
          (map['secondary_muscles'] as String).isNotEmpty
          ? (map['secondary_muscles'] as String)
          .split(',')
          .map((i) => DetailedMuscle.values[int.tryParse(i) ?? 0])
          .toList()
          : [],
      description: map['description'] ?? '',
      instructions: map['instructions'] != null &&
          (map['instructions'] as String).isNotEmpty
          ? (map['instructions'] as String).split('|||')
          : null,
      tips: map['tips'] != null &&
          (map['tips'] as String).isNotEmpty
          ? (map['tips'] as String).split('|||')
          : null,
    );
  }

  // ============ CUSTOM EXERCISE METHODS ============

  Future<Exercise?> _getCustomExercise(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'custom_exercises',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Exercise.fromMap(maps.first);
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    return null;
  }

  Future<String> createCustomExercise(Exercise exercise) async {
    final db = await database;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final customExercise = exercise.copyWith(id: id);

    await db.insert('custom_exercises', customExercise.toMap());

    // Очищаем кеш всех упражнений
    _allExercisesCache = null;

    return id;
  }

  Future<void> deleteExercise(String id) async {
    // Удаляем только кастомные упражнения
    if (id.length <= 10) {
      throw Exception('Cannot delete built-in exercises');
    }

    final db = await database;

    // Проверяем использование в тренировках
    final usageCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM workout_exercises WHERE exerciseId = ?',
        [id],
      ),
    ) ?? 0;

    if (usageCount > 0) {
      throw Exception('Cannot delete exercise that is used in workouts');
    }

    final result = await db.delete(
      'custom_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result == 0) {
      throw Exception('Exercise not found');
    }

    // Очищаем кеш
    _allExercisesCache = null;
    _exerciseCache.remove(id);
  }

  // ============ WORKOUT METHODS ============

  Future<String> createWorkout(Workout workout) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert('workouts', {
        'id': workout.id,
        'name': workout.name,
        'date': workout.date.toIso8601String(),
        'duration': workout.duration.inSeconds,
      });

      for (int i = 0; i < workout.exercises.length; i++) {
        final workoutExercise = workout.exercises[i];

        final workoutExerciseId = await txn.insert('workout_exercises', {
          'workoutId': workout.id,
          'exerciseId': workoutExercise.exercise.id,
          'orderIndex': i,
        });

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

    final workoutMaps = await db.query(
      'workouts',
      orderBy: 'date DESC',
    );

    List<Workout> workouts = [];

    for (final workoutMap in workoutMaps) {
      final workoutExerciseMaps = await db.query(
        'workout_exercises',
        where: 'workoutId = ?',
        whereArgs: [workoutMap['id']],
        orderBy: 'orderIndex',
      );

      List<WorkoutExercise> exercises = [];

      for (final weMap in workoutExerciseMaps) {
        final exercise = await getExercise(weMap['exerciseId'] as String);
        if (exercise == null) continue;

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

  // ============ STATISTICS METHODS ============

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final totalWorkouts = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM workouts')
    ) ?? 0;

    final totalSeconds = Sqflite.firstIntValue(
        await db.rawQuery('SELECT SUM(duration) FROM workouts')
    ) ?? 0;

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

  Future<void> close() async {
    await _database?.close();
    await _exercisesDb?.close();

    _database = null;
    _exercisesDb = null;
    _clearCache();
  }
}