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
  final String? nameRu; // Добавлено
  final DetailedMuscle primaryMuscle;
  final List<DetailedMuscle> secondaryMuscles;
  final String description;
  final String? descriptionRu; // Добавлено
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? instructions;
  final List<String>? instructionsRu; // Добавлено
  final List<String>? tips;
  final List<String>? tipsRu; // Добавлено

  const Exercise({
    required this.id,
    required this.name,
    this.nameRu, // Добавлено
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.description,
    this.descriptionRu, // Добавлено
    this.imageUrl,
    this.videoUrl,
    this.instructions,
    this.instructionsRu, // Добавлено
    this.tips,
    this.tipsRu, // Добавлено
  });

  /// Получить локализованное название
  String getLocalizedName(String language) {
    if (isCustom) return name;
    return language == 'ru' && nameRu != null ? nameRu! : name;
  }

  /// Получить локализованное описание
  String getLocalizedDescription(String language) {
    if (isCustom) return description;
    return language == 'ru' && descriptionRu != null ? descriptionRu! : description;
  }

  /// Получить локализованные инструкции
  List<String>? getLocalizedInstructions(String language) {
    if (isCustom) return instructions;
    return language == 'ru' && instructionsRu != null ? instructionsRu : instructions;
  }

  /// Получить локализованные советы
  List<String>? getLocalizedTips(String language) {
    if (isCustom) return tips;
    return language == 'ru' && tipsRu != null ? tipsRu : tips;
  }

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
      'nameRu': nameRu,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).join('|'),
      'description': description,
      'descriptionRu': descriptionRu,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions?.join('|||'),
      'instructionsRu': instructionsRu?.join('|||'),
      'tips': tips?.join('|||'),
      'tipsRu': tipsRu?.join('|||'),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      nameRu: map['nameRu'] ?? map['name_ru'],
      primaryMuscle: DetailedMuscle.fromString(map['primaryMuscle'] ?? 'middleChest'),
      secondaryMuscles: (map['secondaryMuscles'] as String?)
          ?.split('|')
          .where((s) => s.isNotEmpty)
          .map((s) => DetailedMuscle.fromString(s))
          .toList() ??
          [],
      description: map['description'] ?? '',
      descriptionRu: map['descriptionRu'] ?? map['description_ru'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      instructions: (map['instructions'] as String?)
          ?.split('|||')
          .where((s) => s.isNotEmpty)
          .toList(),
      instructionsRu: (map['instructionsRu'] as String?)
          ?.split('|||')
          .where((s) => s.isNotEmpty)
          .toList() ??
          (map['instructions_ru'] as String?)
              ?.split('|||')
              .where((s) => s.isNotEmpty)
              .toList(),
      tips: (map['tips'] as String?)
          ?.split('|||')
          .where((s) => s.isNotEmpty)
          .toList(),
      tipsRu: (map['tipsRu'] as String?)
          ?.split('|||')
          .where((s) => s.isNotEmpty)
          .toList() ??
          (map['tips_ru'] as String?)
              ?.split('|||')
              .where((s) => s.isNotEmpty)
              .toList(),
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? nameRu,
    DetailedMuscle? primaryMuscle,
    List<DetailedMuscle>? secondaryMuscles,
    String? description,
    String? descriptionRu,
    String? imageUrl,
    String? videoUrl,
    List<String>? instructions,
    List<String>? instructionsRu,
    List<String>? tips,
    List<String>? tipsRu,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      description: description ?? this.description,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      instructions: instructions ?? this.instructions,
      instructionsRu: instructionsRu ?? this.instructionsRu,
      tips: tips ?? this.tips,
      tipsRu: tipsRu ?? this.tipsRu,
    );
  }

  /// Check if exercise is custom
  bool get isCustom => id.length > 10 && RegExp(r'^\d+$').hasMatch(id);
}