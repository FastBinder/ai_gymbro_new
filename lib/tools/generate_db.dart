// lib/tools/generate_db.dart
// Запускать командой: dart run lib/tools/generate_db.dart

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../data/exercises_data.dart';
import '../models/exercise.dart';

void main() async {
  print('🏋️ Starting database generation...');

  // Инициализация FFI для desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Очищаем кеш sqflite
  final cacheDir = Directory('.dart_tool/sqflite_common_ffi/databases');
  if (await cacheDir.exists()) {
    await cacheDir.delete(recursive: true);
    print('🗑️ Cleared sqflite cache');
  }

  // Создаем базу данных с абсолютным путем
  final currentDir = Directory.current.path;
  final dbPath = join(currentDir, 'exercises_temp.db');

  // Удаляем старый файл если существует
  final dbFile = File(dbPath);
  if (await dbFile.exists()) {
    await dbFile.delete();
  }

  final db = await openDatabase(
    dbPath,
    version: 1,
    onCreate: (db, version) async {
      await _createTables(db);
    },
  );

  // Заполняем данными
  await _populateDatabase(db);

  // Создаем индексы и FTS
  await _createIndexes(db);

  // Оптимизируем БД
  await _optimizeDatabase(db);

  // Закрываем БД
  await db.close();

  // Находим где реально создалась БД
  final actualDbPath = await _findGeneratedDb();
  if (actualDbPath == null) {
    throw Exception('Generated database not found!');
  }

  // Копируем в assets
  await _copyToAssets(actualDbPath);

  print('✅ Database generation completed!');
  print('📊 Total exercises: ${ExercisesData.exercises.length}');
}

Future<void> _createTables(Database db) async {
  print('📁 Creating database structure...');

  // Основная таблица упражнений
  await db.execute('''
    CREATE TABLE exercises(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      name_ru TEXT NOT NULL,
      primary_muscle INTEGER NOT NULL,
      secondary_muscles TEXT,
      category INTEGER NOT NULL,
      equipment INTEGER NOT NULL DEFAULT 0,
      difficulty INTEGER NOT NULL DEFAULT 1,
      exercise_type INTEGER NOT NULL DEFAULT 0,
      description TEXT NOT NULL,
      description_ru TEXT NOT NULL,
      instructions TEXT,
      instructions_ru TEXT,
      tips TEXT,
      tips_ru TEXT,
      is_compound INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT 0,
      is_custom INTEGER NOT NULL DEFAULT 0
    )
  ''');

  // Таблица метаданных
  await db.execute('''
    CREATE TABLE metadata(
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
}

Future<void> _populateDatabase(Database db) async {
  print('📝 Populating database with exercises...');

  final batch = db.batch();

  // Вставляем упражнения
  for (var i = 0; i < ExercisesData.exercises.length; i++) {
    final exercise = ExercisesData.exercises[i];

    batch.insert('exercises', {
      'name': exercise.name,
      'name_ru': exercise.nameRu,
      'primary_muscle': exercise.primaryMuscle.index,
      'secondary_muscles': exercise.secondaryMuscles
          .map((m) => m.index.toString())
          .join(','),
      'category': exercise.primaryMuscle.category.index,
      'equipment': exercise.equipment.index,
      'difficulty': exercise.difficulty.index,
      'exercise_type': exercise.exerciseType.index,
      'description': exercise.description,
      'description_ru': exercise.descriptionRu,
      'instructions': exercise.instructions.join('|||'),
      'instructions_ru': exercise.instructionsRu.join('|||'),
      'tips': exercise.tips.join('|||'),
      'tips_ru': exercise.tipsRu.join('|||'),
      'is_compound': exercise.exerciseType == ExerciseType.compound ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_custom': 0,
    });

    if ((i + 1) % 10 == 0) {
      print('  Added ${i + 1} exercises...');
    }
  }

  // Коммитим упражнения
  await batch.commit(noResult: true);

  // Вставляем метаданные отдельно (не в batch)
  await db.insert('metadata', {
    'key': 'version',
    'value': '1',
  });

  await db.insert('metadata', {
    'key': 'generated_at',
    'value': DateTime.now().toIso8601String(),
  });

  await db.insert('metadata', {
    'key': 'exercise_count',
    'value': ExercisesData.exercises.length.toString(),
  });

  print('✅ Added ${ExercisesData.exercises.length} exercises');
}

Future<void> _createIndexes(Database db) async {
  print('🔍 Creating indexes for fast queries...');

  // Индексы для быстрого поиска
  await db.execute('CREATE INDEX idx_category ON exercises(category)');
  await db.execute('CREATE INDEX idx_primary_muscle ON exercises(primary_muscle)');
  await db.execute('CREATE INDEX idx_equipment ON exercises(equipment)');
  await db.execute('CREATE INDEX idx_difficulty ON exercises(difficulty)');
  await db.execute('CREATE INDEX idx_exercise_type ON exercises(exercise_type)');
  await db.execute('CREATE INDEX idx_is_custom ON exercises(is_custom)');

  // Составной индекс для фильтрации
  await db.execute('CREATE INDEX idx_category_equipment ON exercises(category, equipment)');

  // Полнотекстовый поиск
  print('🔤 Creating FTS table...');
  await db.execute('''
    CREATE VIRTUAL TABLE exercises_fts USING fts5(
      name, 
      name_ru, 
      description,
      description_ru,
      content=exercises, 
      content_rowid=id,
      tokenize='unicode61'
    )
  ''');

  // Заполняем FTS таблицу
  await db.execute('''
    INSERT INTO exercises_fts(rowid, name, name_ru, description, description_ru)
    SELECT id, name, name_ru, description, description_ru FROM exercises
  ''');

  // Триггеры для синхронизации FTS
  await db.execute('''
    CREATE TRIGGER exercises_ai AFTER INSERT ON exercises BEGIN
      INSERT INTO exercises_fts(rowid, name, name_ru, description, description_ru) 
      VALUES (new.id, new.name, new.name_ru, new.description, new.description_ru);
    END
  ''');

  await db.execute('''
    CREATE TRIGGER exercises_ad AFTER DELETE ON exercises BEGIN
      DELETE FROM exercises_fts WHERE rowid = old.id;
    END
  ''');

  await db.execute('''
    CREATE TRIGGER exercises_au AFTER UPDATE ON exercises BEGIN
      DELETE FROM exercises_fts WHERE rowid = old.id;
      INSERT INTO exercises_fts(rowid, name, name_ru, description, description_ru) 
      VALUES (new.id, new.name, new.name_ru, new.description, new.description_ru);
    END
  ''');
}

Future<void> _optimizeDatabase(Database db) async {
  print('⚡ Optimizing database...');

  // Анализируем таблицы для оптимизации планировщика запросов
  await db.execute('ANALYZE');

  // Оптимизируем FTS
  await db.execute("INSERT INTO exercises_fts(exercises_fts) VALUES('optimize')");

  // Сжимаем БД
  await db.execute('VACUUM');
}

Future<void> _copyToAssets(String sourcePath) async {
  print('📦 Copying database to assets...');

  final sourceFile = File(sourcePath);

  // Проверяем существование исходного файла
  if (!await sourceFile.exists()) {
    throw Exception('Source database file not found at: $sourcePath');
  }

  final assetsDir = Directory('assets/databases');

  // Создаем директорию если не существует
  if (!await assetsDir.exists()) {
    await assetsDir.create(recursive: true);
  }

  final targetPath = join(assetsDir.path, 'exercises.db');

  // Удаляем старый файл если существует
  final targetFile = File(targetPath);
  if (await targetFile.exists()) {
    await targetFile.delete();
    print('🗑️ Deleted old database in assets');
  }

  // Копируем новый файл
  await sourceFile.copy(targetPath);

  // НЕ удаляем временный файл если это в кеше sqflite
  if (!sourcePath.contains('.dart_tool')) {
    await sourceFile.delete();
  }

  // Выводим информацию о размере
  final sizeInBytes = await targetFile.length();
  final sizeInKB = (sizeInBytes / 1024).toStringAsFixed(2);
  final sizeInMB = (sizeInBytes / (1024 * 1024)).toStringAsFixed(2);

  print('📏 Database size: $sizeInKB KB ($sizeInMB MB)');
  print('📁 Database saved to: $targetPath');
}

Future<String?> _findGeneratedDb() async {
  print('🔍 Looking for generated database...');

  // Проверяем разные возможные места
  final possiblePaths = [
    'exercises_temp.db',
    join(Directory.current.path, 'exercises_temp.db'),
    join('.dart_tool', 'sqflite_common_ffi', 'databases', 'exercises_temp.db'),
  ];

  // Также ищем в кеше sqflite
  final cacheDir = Directory('.dart_tool/sqflite_common_ffi/databases');
  if (await cacheDir.exists()) {
    await for (final file in cacheDir.list()) {
      if (file is File && file.path.endsWith('.db')) {
        print('Found database at: ${file.path}');
        return file.path;
      }
    }
  }

  // Проверяем все возможные пути
  for (final path in possiblePaths) {
    final file = File(path);
    if (await file.exists()) {
      print('Found database at: $path');
      return path;
    }
  }

  return null;
}

// Для запуска:
// 1. Добавьте в pubspec.yaml:
//    dev_dependencies:
//      sqflite_common_ffi: ^2.3.0
//
// 2. Запустите:
//    dart run lib/tools/generate_db.dart