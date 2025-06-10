// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_plan.dart';

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
  static const int MAIN_DB_VERSION = 5; // Увеличиваем версию для миграции

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
      version: MAIN_DB_VERSION,
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

    // Таблица планов тренировок
    await db.execute('''
      CREATE TABLE workout_plans(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        lastUsedAt TEXT,
        timesUsed INTEGER DEFAULT 0,
        type INTEGER DEFAULT 0,
        tags TEXT
      )
    ''');

    // Таблица упражнений в плане
    await db.execute('''
      CREATE TABLE plan_exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        orderIndex INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (planId) REFERENCES workout_plans (id) ON DELETE CASCADE
      )
    ''');

    // Таблица запланированных подходов
    await db.execute('''
      CREATE TABLE planned_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planExerciseId INTEGER NOT NULL,
        targetReps INTEGER NOT NULL,
        targetWeight REAL,
        restSeconds INTEGER DEFAULT 90,
        orderIndex INTEGER NOT NULL,
        FOREIGN KEY (planExerciseId) REFERENCES plan_exercises (id) ON DELETE CASCADE
      )
    ''');

    // Индексы для производительности
    await db.execute('CREATE INDEX idx_workout_date ON workouts(date DESC)');
    await db.execute('CREATE INDEX idx_workout_exercises ON workout_exercises(workoutId, orderIndex)');
    await db.execute('CREATE INDEX idx_sets ON sets(workoutExerciseId)');
    await db.execute('CREATE INDEX idx_plan_exercises ON plan_exercises(planId, orderIndex)');
    await db.execute('CREATE INDEX idx_planned_sets ON planned_sets(planExerciseId, orderIndex)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
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

    if (oldVersion < 5) {
      // Добавляем таблицы для планов тренировок
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_plans(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          createdAt TEXT NOT NULL,
          lastUsedAt TEXT,
          timesUsed INTEGER DEFAULT 0,
          type INTEGER DEFAULT 0,
          tags TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS plan_exercises(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          planId TEXT NOT NULL,
          exerciseId TEXT NOT NULL,
          orderIndex INTEGER NOT NULL,
          notes TEXT,
          FOREIGN KEY (planId) REFERENCES workout_plans (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS planned_sets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          planExerciseId INTEGER NOT NULL,
          targetReps INTEGER NOT NULL,
          targetWeight REAL,
          restSeconds INTEGER DEFAULT 90,
          orderIndex INTEGER NOT NULL,
          FOREIGN KEY (planExerciseId) REFERENCES plan_exercises (id) ON DELETE CASCADE
        )
      ''');

      // Создаем индексы
      await db.execute('CREATE INDEX IF NOT EXISTS idx_plan_exercises ON plan_exercises(planId, orderIndex)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_planned_sets ON planned_sets(planExerciseId, orderIndex)');
    }
  }

  // ============ WORKOUT PLAN METHODS ============

  Future<String> createWorkoutPlan(WorkoutPlan plan) async {
    final db = await database;

    await db.transaction((txn) async {
      // Сохраняем план
      await txn.insert('workout_plans', {
        'id': plan.id,
        'name': plan.name,
        'description': plan.description,
        'createdAt': plan.createdAt.toIso8601String(),
        'lastUsedAt': plan.lastUsedAt?.toIso8601String(),
        'timesUsed': plan.timesUsed,
        'type': plan.type.index,
        'tags': plan.tags.join(','),
      });

      // Сохраняем упражнения
      for (int i = 0; i < plan.exercises.length; i++) {
        final planExercise = plan.exercises[i];

        final planExerciseId = await txn.insert('plan_exercises', {
          'planId': plan.id,
          'exerciseId': planExercise.exercise.id,
          'orderIndex': i,
          'notes': planExercise.notes,
        });

        // Сохраняем запланированные подходы
        for (int j = 0; j < planExercise.plannedSets.length; j++) {
          final set = planExercise.plannedSets[j];

          await txn.insert('planned_sets', {
            'planExerciseId': planExerciseId,
            'targetReps': set.targetReps,
            'targetWeight': set.targetWeight,
            'restSeconds': set.restSeconds,
            'orderIndex': j,
          });
        }
      }
    });

    return plan.id;
  }

  Future<List<WorkoutPlan>> getAllWorkoutPlans() async {
    final db = await database;
    final allExercises = await getAllExercises();

    final planMaps = await db.query(
      'workout_plans',
      orderBy: 'lastUsedAt DESC, createdAt DESC',
    );

    final plans = <WorkoutPlan>[];

    for (final planMap in planMaps) {
      final planExerciseMaps = await db.query(
        'plan_exercises',
        where: 'planId = ?',
        whereArgs: [planMap['id']],
        orderBy: 'orderIndex',
      );

      final exercises = <PlannedExercise>[];

      for (final peMap in planExerciseMaps) {
        final exercise = allExercises.firstWhere(
              (e) => e.id == peMap['exerciseId'],
          orElse: () => throw Exception('Exercise not found: ${peMap['exerciseId']}'),
        );

        final setMaps = await db.query(
          'planned_sets',
          where: 'planExerciseId = ?',
          whereArgs: [peMap['id']],
          orderBy: 'orderIndex',
        );

        final plannedSets = setMaps.map((setMap) => PlannedSet(
          targetReps: setMap['targetReps'] as int,
          targetWeight: setMap['targetWeight'] as double?,
          restSeconds: setMap['restSeconds'] as int,
        )).toList();

        exercises.add(PlannedExercise(
          exercise: exercise,
          plannedSets: plannedSets,
          notes: peMap['notes'] as String?,
        ));
      }

      plans.add(WorkoutPlan(
        id: planMap['id'] as String,
        name: planMap['name'] as String,
        description: planMap['description'] as String?,
        exercises: exercises,
        createdAt: DateTime.parse(planMap['createdAt'] as String),
        lastUsedAt: planMap['lastUsedAt'] != null
            ? DateTime.parse(planMap['lastUsedAt'] as String)
            : null,
        timesUsed: planMap['timesUsed'] as int,
        type: WorkoutPlanType.values[planMap['type'] as int],
        tags: (planMap['tags'] as String?)?.split(',') ?? [],
      ));
    }

    return plans;
  }

  Future<WorkoutPlan?> getWorkoutPlan(String id) async {
    final plans = await getAllWorkoutPlans();
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateWorkoutPlan(WorkoutPlan plan) async {
    await deleteWorkoutPlan(plan.id);
    await createWorkoutPlan(plan);
  }

  Future<void> deleteWorkoutPlan(String id) async {
    final db = await database;
    await db.delete(
      'workout_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markPlanAsUsed(String planId) async {
    final db = await database;

    await db.rawUpdate('''
      UPDATE workout_plans 
      SET lastUsedAt = ?, timesUsed = timesUsed + 1 
      WHERE id = ?
    ''', [DateTime.now().toIso8601String(), planId]);
  }

  Future<WorkoutPlan> createPlanFromWorkout(Workout workout, String planName) async {
    final plannedExercises = <PlannedExercise>[];

    for (var workoutExercise in workout.exercises) {
      if (workoutExercise.sets.isEmpty) continue;

      // Берем средние значения из выполненных подходов
      final avgWeight = workoutExercise.sets
          .map((s) => s.weight)
          .reduce((a, b) => a + b) / workoutExercise.sets.length;

      final plannedSets = workoutExercise.sets.map((set) => PlannedSet(
        targetReps: set.reps,
        targetWeight: avgWeight,
        restSeconds: 90,
      )).toList();

      plannedExercises.add(PlannedExercise(
        exercise: workoutExercise.exercise,
        plannedSets: plannedSets,
      ));
    }

    final plan = WorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: planName,
      description: 'Created from workout on ${_formatDate(workout.date)}',
      exercises: plannedExercises,
      createdAt: DateTime.now(),
      type: WorkoutPlanType.custom,
    );

    await createWorkoutPlan(plan);
    return plan;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
      nameRu: map['name_ru'], // Добавлено
      primaryMuscle: DetailedMuscle.values[map['primary_muscle'] ?? 0],
      secondaryMuscles: map['secondary_muscles'] != null &&
          (map['secondary_muscles'] as String).isNotEmpty
          ? (map['secondary_muscles'] as String)
          .split(',')
          .map((i) => DetailedMuscle.values[int.tryParse(i) ?? 0])
          .toList()
          : [],
      description: map['description'] ?? '',
      descriptionRu: map['description_ru'], // Добавлено
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      instructions: map['instructions'] != null &&
          (map['instructions'] as String).isNotEmpty
          ? (map['instructions'] as String).split('|||')
          : null,
      instructionsRu: map['instructions_ru'] != null && // Добавлено
          (map['instructions_ru'] as String).isNotEmpty
          ? (map['instructions_ru'] as String).split('|||')
          : null,
      tips: map['tips'] != null &&
          (map['tips'] as String).isNotEmpty
          ? (map['tips'] as String).split('|||')
          : null,
      tipsRu: map['tips_ru'] != null && // Добавлено
          (map['tips_ru'] as String).isNotEmpty
          ? (map['tips_ru'] as String).split('|||')
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

    // Сохраняем с правильным форматом для custom_exercises
    final customExerciseMap = {
      'id': id,
      'name': exercise.name,
      'primaryMuscle': exercise.primaryMuscle.name,
      'secondaryMuscles': exercise.secondaryMuscles.map((m) => m.name).join('|'),
      'description': exercise.description,
      'imageUrl': exercise.imageUrl,
      'videoUrl': exercise.videoUrl,
      'instructions': exercise.instructions?.join('|||'),
      'tips': exercise.tips?.join('|||'),
    };

    await db.insert('custom_exercises', customExerciseMap);

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