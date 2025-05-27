// lib/models/exercise.dart

/// Перечисление всех групп мышц для type safety
enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  abs,
  obliques,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  traps,
  lats,
  middleBack,
  lowerBack,
  frontDelts,
  sideDelts,
  rearDelts;

  // Для сериализации/десериализации
  static MuscleGroup fromString(String value) {
    return MuscleGroup.values.firstWhere(
          (e) => e.name == value,
      orElse: () => MuscleGroup.chest,
    );
  }
}

// Extension для получения ключа локализации
extension MuscleGroupExtension on MuscleGroup {
  String get localizationKey => 'muscle_$name';

  // Для обратной совместимости, пока не обновите все использования
  @Deprecated('Use localization service instead')
  String get russianName {
    switch (this) {
      case MuscleGroup.chest: return 'Грудь';
      case MuscleGroup.back: return 'Спина';
      case MuscleGroup.shoulders: return 'Плечи';
      case MuscleGroup.biceps: return 'Бицепс';
      case MuscleGroup.triceps: return 'Трицепс';
      case MuscleGroup.forearms: return 'Предплечья';
      case MuscleGroup.abs: return 'Пресс';
      case MuscleGroup.obliques: return 'Косые мышцы';
      case MuscleGroup.quadriceps: return 'Квадрицепс';
      case MuscleGroup.hamstrings: return 'Бицепс бедра';
      case MuscleGroup.glutes: return 'Ягодицы';
      case MuscleGroup.calves: return 'Икры';
      case MuscleGroup.traps: return 'Трапеция';
      case MuscleGroup.lats: return 'Широчайшие';
      case MuscleGroup.middleBack: return 'Середина спины';
      case MuscleGroup.lowerBack: return 'Поясница';
      case MuscleGroup.frontDelts: return 'Передние дельты';
      case MuscleGroup.sideDelts: return 'Средние дельты';
      case MuscleGroup.rearDelts: return 'Задние дельты';
    }
  }
}

/// Модель упражнения с основной и побочными группами мышц
class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
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

  /// Все задействованные мышцы (основная + побочные)
  List<MuscleGroup> get allMuscles => [primaryMuscle, ...secondaryMuscles];

  /// Проверка, задействована ли определенная группа мышц
  bool involvesMuscle(MuscleGroup muscle) {
    return primaryMuscle == muscle || secondaryMuscles.contains(muscle);
  }

  /// Получить все группы мышц как строку для отображения (deprecated)
  @Deprecated('Use UI layer with localization service')
  String get muscleGroupsDisplay {
    if (secondaryMuscles.isEmpty) {
      return primaryMuscle.russianName;
    }
    final secondary = secondaryMuscles
        .map((m) => m.russianName)
        .join(', ');
    return '${primaryMuscle.russianName} (${secondary})';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).join('|'), // Изменен разделитель
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions?.join('|||'), // Уникальный разделитель
      'tips': tips?.join('|||'),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      primaryMuscle: MuscleGroup.fromString(map['primaryMuscle']),
      secondaryMuscles: (map['secondaryMuscles'] as String?)
          ?.split('|')
          .where((s) => s.isNotEmpty)
          .map((s) => MuscleGroup.fromString(s))
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
    MuscleGroup? primaryMuscle,
    List<MuscleGroup>? secondaryMuscles,
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

/// База данных упражнений (минимальная для тестирования)
class ExerciseDatabase {
  static final List<Exercise> exercises = [
    // Тестовое упражнение 1: Жим лежа
    Exercise(
      id: '1',
      name: 'Barbell Bench Press',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.frontDelts],
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

    // Тестовое упражнение 2: Подтягивания
    Exercise(
      id: '2',
      name: 'Pull-ups',
      primaryMuscle: MuscleGroup.lats,
      secondaryMuscles: [
        MuscleGroup.middleBack,
        MuscleGroup.biceps,
        MuscleGroup.rearDelts
      ],
      description: 'Compound exercise for lats and upper back',
      instructions: [
        'Hang from bar with overhand grip',
        'Pull body up until chin over bar',
        'Lower with control'
      ],
    ),

    // Тестовое упражнение 3: Приседания
    Exercise(
      id: '3',
      name: 'Barbell Squat',
      primaryMuscle: MuscleGroup.quadriceps,
      secondaryMuscles: [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
        MuscleGroup.calves
      ],
      description: 'King of all leg exercises',
      instructions: [
        'Position bar on upper traps',
        'Squat down until thighs parallel',
        'Drive up through heels'
      ],
    ),
  ];

  /// Получить упражнения по основной группе мышц
  static List<Exercise> getByPrimaryMuscle(MuscleGroup muscle) {
    return exercises
        .where((exercise) => exercise.primaryMuscle == muscle)
        .toList();
  }

  /// Получить все упражнения, которые задействуют определенную группу мышц
  static List<Exercise> getByMuscleInvolvement(MuscleGroup muscle) {
    return exercises
        .where((exercise) => exercise.involvesMuscle(muscle))
        .toList();
  }

  /// Получить уникальные группы мышц из всех упражнений
  static Set<MuscleGroup> getAllUsedMuscleGroups() {
    final groups = <MuscleGroup>{};
    for (final exercise in exercises) {
      groups.add(exercise.primaryMuscle);
      groups.addAll(exercise.secondaryMuscles);
    }
    return groups;
  }
}