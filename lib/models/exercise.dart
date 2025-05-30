// lib/models/exercise.dart

/// Основные группы мышц для фильтрации
enum MuscleCategory {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  legs;

  static MuscleCategory fromString(String value) {
    return MuscleCategory.values.firstWhere(
          (e) => e.name == value,
      orElse: () => MuscleCategory.chest,
    );
  }
}

/// Детальные мышцы
enum DetailedMuscle {
  // Грудь
  upperChest,
  middleChest,
  lowerChest,
  innerChest,
  outerChest,

  // Спина
  lats,
  upperTraps,
  middleTraps,
  lowerTraps,
  rhomboids,
  teresMajor,
  teresMinor,
  infraspinatus,
  erectorSpinae,
  lowerBack,

  // Плечи
  frontDelts,
  sideDelts,
  rearDelts,

  // Руки
  biceps,
  longHeadTriceps,
  lateralHeadTriceps,
  medialHeadTriceps,
  forearms,

  // Ноги
  quadriceps,
  hamstrings,
  glutes,
  calves,
  adductors,
  abductors,

  // Корпус
  abs,
  obliques;

  static DetailedMuscle fromString(String value) {
    return DetailedMuscle.values.firstWhere(
          (e) => e.name == value,
      orElse: () => DetailedMuscle.middleChest,
    );
  }
}

// Extension для получения категории из детальной мышцы
extension DetailedMuscleExtension on DetailedMuscle {
  MuscleCategory get category {
    switch (this) {
      case DetailedMuscle.upperChest:
      case DetailedMuscle.middleChest:
      case DetailedMuscle.lowerChest:
      case DetailedMuscle.innerChest:
      case DetailedMuscle.outerChest:
        return MuscleCategory.chest;

      case DetailedMuscle.lats:
      case DetailedMuscle.upperTraps:
      case DetailedMuscle.middleTraps:
      case DetailedMuscle.lowerTraps:
      case DetailedMuscle.rhomboids:
      case DetailedMuscle.teresMajor:
      case DetailedMuscle.teresMinor:
      case DetailedMuscle.infraspinatus:
      case DetailedMuscle.erectorSpinae:
      case DetailedMuscle.lowerBack:
        return MuscleCategory.back;

      case DetailedMuscle.frontDelts:
      case DetailedMuscle.sideDelts:
      case DetailedMuscle.rearDelts:
        return MuscleCategory.shoulders;

      case DetailedMuscle.biceps:
        return MuscleCategory.biceps;

      case DetailedMuscle.longHeadTriceps:
      case DetailedMuscle.lateralHeadTriceps:
      case DetailedMuscle.medialHeadTriceps:
        return MuscleCategory.triceps;

      case DetailedMuscle.forearms:
        return MuscleCategory.biceps; // Группируем с бицепсом

      case DetailedMuscle.quadriceps:
      case DetailedMuscle.hamstrings:
      case DetailedMuscle.glutes:
      case DetailedMuscle.calves:
      case DetailedMuscle.adductors:
      case DetailedMuscle.abductors:
      case DetailedMuscle.abs:
      case DetailedMuscle.obliques:
        return MuscleCategory.legs;
    }
  }

  String get localizationKey => 'muscle_$name';
}

// Extension для категорий
extension MuscleCategoryExtension on MuscleCategory {
  String get localizationKey => 'category_$name';
}

/// Модель упражнения с детальными мышцами
class Exercise {
  final String id;
  final String name;
  final DetailedMuscle primaryMuscle;
  final List<DetailedMuscle> secondaryMuscles;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? instructions;
  final List<String>? tips;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.instructions,
    this.tips,
  });

  /// Все задействованные мышцы
  List<DetailedMuscle> get allMuscles => [primaryMuscle, ...secondaryMuscles];

  /// Получить все задействованные категории
  Set<MuscleCategory> get involvedCategories {
    return allMuscles.map((m) => m.category).toSet();
  }

  /// Основная категория
  MuscleCategory get primaryCategory => primaryMuscle.category;

  /// Проверка, задействована ли категория
  bool involvesCategory(MuscleCategory category) {
    return involvedCategories.contains(category);
  }

  /// Проверка, задействована ли определенная мышца
  bool involvesMuscle(DetailedMuscle muscle) {
    return primaryMuscle == muscle || secondaryMuscles.contains(muscle);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).join('|'),
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions?.join('|||'),
      'tips': tips?.join('|||'),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      primaryMuscle: DetailedMuscle.fromString(map['primaryMuscle']),
      secondaryMuscles: (map['secondaryMuscles'] as String?)
          ?.split('|')
          .where((s) => s.isNotEmpty)
          .map((s) => DetailedMuscle.fromString(s))
          .toList() ??
          [],
      description: map['description'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      instructions: (map['instructions'] as String?)
          ?.split('|||')
          .where((s) => s.isNotEmpty)
          .toList(),
      tips: (map['tips'] as String?)
          ?.split('|||')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    DetailedMuscle? primaryMuscle,
    List<DetailedMuscle>? secondaryMuscles,
    String? description,
    String? imageUrl,
    String? videoUrl,
    List<String>? instructions,
    List<String>? tips,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
    );
  }
}

/// База данных упражнений (примеры)
class ExerciseDatabase {
  static final List<Exercise> exercises = [
    // Упражнения на грудь
    Exercise(
      id: '1',
      name: 'Barbell Bench Press',
      primaryMuscle: DetailedMuscle.middleChest,
      secondaryMuscles: [
        DetailedMuscle.longHeadTriceps,
        DetailedMuscle.lateralHeadTriceps,
        DetailedMuscle.frontDelts
      ],
      description: 'Fundamental exercise for chest development',
      instructions: [
        'Lie on bench with eyes under the bar',
        'Grip the bar slightly wider than shoulders',
        'Lower the bar to your chest',
        'Press the bar up to starting position'
      ],
      tips: [
        'Keep shoulder blades retracted',
        'Plant feet firmly on the floor',
        'Maintain tight core throughout'
      ],
    ),

    Exercise(
      id: '2',
      name: 'Incline Dumbbell Press',
      primaryMuscle: DetailedMuscle.upperChest,
      secondaryMuscles: [
        DetailedMuscle.frontDelts,
        DetailedMuscle.longHeadTriceps
      ],
      description: 'Targets upper chest development',
    ),

    // Упражнения на спину
    Exercise(
      id: '3',
      name: 'Pull-ups',
      primaryMuscle: DetailedMuscle.lats,
      secondaryMuscles: [
        DetailedMuscle.biceps,
        DetailedMuscle.rhomboids,
        DetailedMuscle.middleTraps,
        DetailedMuscle.rearDelts
      ],
      description: 'Compound exercise for lats and upper back',
      instructions: [
        'Hang from bar with overhand grip',
        'Pull body up until chin over bar',
        'Lower with control'
      ],
    ),

    Exercise(
      id: '4',
      name: 'Barbell Row',
      primaryMuscle: DetailedMuscle.rhomboids,
      secondaryMuscles: [
        DetailedMuscle.lats,
        DetailedMuscle.middleTraps,
        DetailedMuscle.biceps,
        DetailedMuscle.rearDelts
      ],
      description: 'Compound back exercise for thickness',
    ),

    // Упражнения на ноги
    Exercise(
      id: '5',
      name: 'Barbell Squat',
      primaryMuscle: DetailedMuscle.quadriceps,
      secondaryMuscles: [
        DetailedMuscle.glutes,
        DetailedMuscle.hamstrings,
        DetailedMuscle.calves,
        DetailedMuscle.erectorSpinae
      ],
      description: 'King of all leg exercises',
      instructions: [
        'Position bar on upper traps',
        'Squat down until thighs parallel',
        'Drive up through heels'
      ],
    ),

    // Упражнения на плечи
    Exercise(
      id: '6',
      name: 'Overhead Press',
      primaryMuscle: DetailedMuscle.frontDelts,
      secondaryMuscles: [
        DetailedMuscle.sideDelts,
        DetailedMuscle.longHeadTriceps,
        DetailedMuscle.upperChest
      ],
      description: 'Fundamental shoulder exercise',
    ),

    // Упражнения на бицепс
    Exercise(
      id: '7',
      name: 'Barbell Curl',
      primaryMuscle: DetailedMuscle.biceps,
      secondaryMuscles: [
        DetailedMuscle.forearms
      ],
      description: 'Classic bicep builder',
    ),

    // Упражнения на трицепс
    Exercise(
      id: '8',
      name: 'Close-Grip Bench Press',
      primaryMuscle: DetailedMuscle.longHeadTriceps,
      secondaryMuscles: [
        DetailedMuscle.lateralHeadTriceps,
        DetailedMuscle.medialHeadTriceps,
        DetailedMuscle.innerChest,
        DetailedMuscle.frontDelts
      ],
      description: 'Compound tricep exercise',
    ),
  ];

  // Маппинг старых MuscleGroup на новые DetailedMuscle для миграции
  static final Map<String, DetailedMuscle> migrationMap = {
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

  /// Получить упражнения по категории
  static List<Exercise> getByCategory(MuscleCategory category) {
    return exercises
        .where((exercise) => exercise.involvesCategory(category))
        .toList();
  }

  /// Получить упражнения по основной категории
  static List<Exercise> getByPrimaryCategory(MuscleCategory category) {
    return exercises
        .where((exercise) => exercise.primaryCategory == category)
        .toList();
  }

  /// Получить упражнения по детальной мышце
  static List<Exercise> getByMuscle(DetailedMuscle muscle) {
    return exercises
        .where((exercise) => exercise.involvesMuscle(muscle))
        .toList();
  }
}