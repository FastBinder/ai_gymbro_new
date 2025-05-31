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

  /// Get localized name from ID
  String getLocalizedName(String Function(String) localizationGetter) {
    // For custom exercises (ID is timestamp), return the original name
    if (id.length > 10 && RegExp(r'^\d+$').hasMatch(id)) {
      return name;
    }
    // For built-in exercises, try to get localized name from ID
    // If localization not found, return original name
    final localizedName = localizationGetter(id);
    return localizedName == id ? name : localizedName;
  }

  /// Check if exercise is custom
  bool get isCustom => id.length > 10 && RegExp(r'^\d+$').hasMatch(id);
}