// lib/services/localization_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  // Загрузка сохраненного языка
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'en';
    notifyListeners();
  }

  // Изменение языка
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    _currentLanguage = language;
    notifyListeners();
  }

  // Получение локализованной строки
  String get(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  // Все переводы
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Navigation
      'nav_workout': 'WORKOUT',
      'nav_exercises': 'EXERCISES',
      'nav_progress': 'PROGRESS',
      'nav_profile': 'PROFILE',

      // Workout Page
      'start_workout': 'START WORKOUT',
      'finish_workout': 'FINISH WORKOUT',
      'add_exercise': 'ADD EXERCISE',
      'select_exercise': 'SELECT EXERCISE',
      'workout_time': 'WORKOUT TIME',
      'rest': 'REST',
      'set': 'SET',
      'start_set': 'START SET',
      'complete': 'COMPLETE',
      'active': 'ACTIVE',
      'complete_set': 'COMPLETE SET',
      'same_as_last_set': 'SAME AS LAST SET',
      'or_enter_manually': 'OR ENTER MANUALLY',
      'weight_kg': 'Weight (kg)',
      'reps': 'Reps',
      'save': 'SAVE',
      'cancel': 'CANCEL',
      'delete': 'DELETE',
      'no_workouts_yet': 'No workouts yet',
      'start_first_workout': 'Start your first workout and crush your goals!',
      'delete_workout_question': 'Delete Workout?',
      'action_cannot_be_undone': 'This action cannot be undone.',
      'workout_deleted': 'Workout deleted',
      'workout_saved': 'Workout saved!',
      'add_at_least_one_exercise': 'Add at least one exercise',
      'exercises': 'exercises',

      // Exercises Page
      'search_exercises': 'Search exercises...',
      'show_secondary_muscles': 'Show secondary muscles',
      'no_exercises_found': 'No exercises found',
      'try_different_filters': 'Try different filters or add a custom exercise',
      'add_custom_exercise': 'ADD CUSTOM EXERCISE',
      'custom': 'CUSTOM',
      'description': 'DESCRIPTION',
      'instructions': 'INSTRUCTIONS',
      'pro_tips': 'PRO TIPS',
      'close': 'Close',
      'delete_custom_exercise': 'Delete Custom Exercise?',
      'are_you_sure_delete': 'Are you sure you want to delete',
      'exercise_deleted': 'Exercise deleted',
      'added_to_exercises': 'Added "{name}" to exercises',
      'exercise_name': 'Exercise name',
      'please_enter_exercise_name': 'Please enter exercise name',
      'name_must_be_3_chars': 'Name must be at least 3 characters',
      'primary_muscle_group': 'PRIMARY MUSCLE GROUP',
      'secondary_muscle_groups': 'SECONDARY MUSCLE GROUPS',
      'brief_description': 'Brief description of the exercise',
      'custom_exercises_saved': 'Custom exercises will be saved and available for all future workouts',
      'save_exercise': 'Save',
      'all': 'All',

      // Progress Page
      'this_week': 'THIS WEEK',
      'all_time': 'ALL TIME',
      'no_workouts_this_week': 'No workouts this week',
      'start_training_week': 'Start training to see your weekly progress!',
      'no_workouts_yet_progress': 'No workouts yet',
      'complete_first_workout': 'Complete your first workout to see progress!',
      'week_summary': 'WEEK SUMMARY',
      'all_time_stats': 'ALL TIME STATS',
      'workouts': 'Workouts',
      'sets': 'Sets',
      'volume': 'Volume',
      'total_time': 'Total Time',
      'streak': 'Streak',
      'days': 'days',
      'training_level': 'TRAINING LEVEL',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'sets_range': '{min}-{max} sets',
      'muscle_visualization': 'MUSCLE VISUALIZATION',
      'coming_soon': 'COMING SOON',
      'visual_body_representation': 'Visual body representation with muscle group highlights',
      'weekly_sets_by_muscle': 'Weekly Sets by Muscle Group',
      'strength_progress': 'Strength Progress',
      'total_sets_by_muscle': 'Total Sets by Muscle Group',
      'target': 'Target',
      'of_max': 'of max',
      'first': 'First',
      'current': 'Current',
      'performed_times': 'Performed {count} times',

      // Profile Page
      'statistics': 'STATISTICS',
      'total_workouts': 'Total Workouts',
      'current_streak': 'Current Streak',
      'settings': 'SETTINGS',
      'app_language': 'App Language',
      'data_management': 'DATA MANAGEMENT',
      'data_size': 'Data size',
      'export_data': 'Export Data',
      'import_data': 'Import Data',
      'exporting_data': 'Exporting data...',
      'importing_data': 'Importing data...',
      'data_exported_successfully': 'Data exported successfully',
      'data_imported_successfully': 'Data imported successfully',
      'export_error': 'Export error',
      'import_error': 'Import error',
      'language_changed': 'Language changed. Please restart the app to apply changes.',

      // Muscle Categories
      'category_chest': 'Chest',
      'category_back': 'Back',
      'category_shoulders': 'Shoulders',
      'category_biceps': 'Biceps',
      'category_triceps': 'Triceps',
      'category_legs': 'Legs',

      // Detailed Muscles - Chest
      'muscle_upperChest': 'Upper Chest',
      'muscle_middleChest': 'Middle Chest',
      'muscle_lowerChest': 'Lower Chest',
      'muscle_innerChest': 'Inner Chest',
      'muscle_outerChest': 'Outer Chest',

      // Detailed Muscles - Back
      'muscle_lats': 'Lats',
      'muscle_upperTraps': 'Upper Traps',
      'muscle_middleTraps': 'Middle Traps',
      'muscle_lowerTraps': 'Lower Traps',
      'muscle_rhomboids': 'Rhomboids',
      'muscle_teresMajor': 'Teres Major',
      'muscle_teresMinor': 'Teres Minor',
      'muscle_infraspinatus': 'Infraspinatus',
      'muscle_erectorSpinae': 'Erector Spinae',
      'muscle_lowerBack': 'Lower Back',

      // Detailed Muscles - Shoulders
      'muscle_frontDelts': 'Front Delts',
      'muscle_sideDelts': 'Side Delts',
      'muscle_rearDelts': 'Rear Delts',

      // Detailed Muscles - Arms
      'muscle_biceps': 'Biceps',
      'muscle_longHeadTriceps': 'Long Head',
      'muscle_lateralHeadTriceps': 'Lateral Head',
      'muscle_medialHeadTriceps': 'Medial Head',
      'muscle_forearms': 'Forearms',

      // Detailed Muscles - Legs
      'muscle_quadriceps': 'Quadriceps',
      'muscle_hamstrings': 'Hamstrings',
      'muscle_glutes': 'Glutes',
      'muscle_calves': 'Calves',
      'muscle_adductors': 'Adductors',
      'muscle_abductors': 'Abductors',

      // Detailed Muscles - Core
      'muscle_abs': 'Abs',
      'muscle_obliques': 'Obliques',

      // Progress View Toggle
      'view_mode': 'View Mode',
      'basic_muscles': 'Basic Muscles',
      'detailed_muscles': 'Detailed Muscles',
    },

    'ru': {
      // Navigation
      'nav_workout': 'ТРЕНИРОВКА',
      'nav_exercises': 'УПРАЖНЕНИЯ',
      'nav_progress': 'ПРОГРЕСС',
      'nav_profile': 'ПРОФИЛЬ',

      // Workout Page
      'start_workout': 'НАЧАТЬ ТРЕНИРОВКУ',
      'finish_workout': 'ЗАВЕРШИТЬ ТРЕНИРОВКУ',
      'add_exercise': 'ДОБАВИТЬ УПРАЖНЕНИЕ',
      'select_exercise': 'ВЫБРАТЬ УПРАЖНЕНИЕ',
      'workout_time': 'ВРЕМЯ ТРЕНИРОВКИ',
      'rest': 'ОТДЫХ',
      'set': 'ПОДХОД',
      'start_set': 'НАЧАТЬ',
      'complete': 'ЗАВЕРШИТЬ',
      'active': 'АКТИВНО',
      'complete_set': 'ЗАВЕРШИТЬ ПОДХОД',
      'same_as_last_set': 'КАК В ПРОШЛОМ ПОДХОДЕ',
      'or_enter_manually': 'ИЛИ ВВЕДИТЕ ВРУЧНУЮ',
      'weight_kg': 'Вес (кг)',
      'reps': 'Повторения',
      'save': 'СОХРАНИТЬ',
      'cancel': 'ОТМЕНА',
      'delete': 'УДАЛИТЬ',
      'no_workouts_yet': 'Пока нет тренировок',
      'start_first_workout': 'Начните первую тренировку и достигайте целей!',
      'delete_workout_question': 'Удалить тренировку?',
      'action_cannot_be_undone': 'Это действие нельзя отменить.',
      'workout_deleted': 'Тренировка удалена',
      'workout_saved': 'Тренировка сохранена!',
      'add_at_least_one_exercise': 'Добавьте хотя бы одно упражнение',
      'exercises': 'упражнений',

      // Exercises Page
      'search_exercises': 'Поиск упражнений...',
      'show_secondary_muscles': 'Показать побочные мышцы',
      'no_exercises_found': 'Упражнения не найдены',
      'try_different_filters': 'Попробуйте другие фильтры или добавьте свое упражнение',
      'add_custom_exercise': 'ДОБАВИТЬ УПРАЖНЕНИЕ',
      'custom': 'СВОЕ',
      'description': 'ОПИСАНИЕ',
      'instructions': 'ИНСТРУКЦИИ',
      'pro_tips': 'СОВЕТЫ',
      'close': 'Закрыть',
      'delete_custom_exercise': 'Удалить упражнение?',
      'are_you_sure_delete': 'Вы уверены, что хотите удалить',
      'exercise_deleted': 'Упражнение удалено',
      'added_to_exercises': 'Добавлено "{name}" в упражнения',
      'exercise_name': 'Название упражнения',
      'please_enter_exercise_name': 'Пожалуйста, введите название упражнения',
      'name_must_be_3_chars': 'Название должно быть не менее 3 символов',
      'primary_muscle_group': 'ОСНОВНАЯ ГРУППА МЫШЦ',
      'secondary_muscle_groups': 'ПОБОЧНЫЕ ГРУППЫ МЫШЦ',
      'brief_description': 'Краткое описание упражнения',
      'custom_exercises_saved': 'Пользовательские упражнения будут сохранены и доступны для всех будущих тренировок',
      'save_exercise': 'ОК',
      'all': 'Все',

      // Progress Page
      'this_week': 'ЭТА НЕДЕЛЯ',
      'all_time': 'ВСЕ ВРЕМЯ',
      'no_workouts_this_week': 'Нет тренировок на этой неделе',
      'start_training_week': 'Начните тренироваться, чтобы увидеть недельный прогресс!',
      'no_workouts_yet_progress': 'Пока нет тренировок',
      'complete_first_workout': 'Завершите первую тренировку, чтобы увидеть прогресс!',
      'week_summary': 'ИТОГИ НЕДЕЛИ',
      'all_time_stats': 'ОБЩАЯ СТАТИСТИКА',
      'workouts': 'Тренировки',
      'sets': 'Подходы',
      'volume': 'Объем',
      'total_time': 'Общее время',
      'streak': 'Серия',
      'days': 'дней',
      'training_level': 'УРОВЕНЬ ПОДГОТОВКИ',
      'beginner': 'Новичок',
      'intermediate': 'Средний',
      'advanced': 'Продвинутый',
      'sets_range': '{min}-{max} сетов',
      'muscle_visualization': 'ВИЗУАЛИЗАЦИЯ МЫШЦ',
      'coming_soon': 'СКОРО',
      'visual_body_representation': 'Визуальное представление тела с подсветкой групп мышц',
      'weekly_sets_by_muscle': 'Недельные подходы по группам мышц',
      'strength_progress': 'Прогресс силы',
      'total_sets_by_muscle': 'Всего подходов по группам мышц',
      'target': 'Цель',
      'of_max': 'от макс',
      'first': 'Первый',
      'current': 'Текущий',
      'performed_times': 'Выполнено {count} раз',

      // Profile Page
      'statistics': 'СТАТИСТИКА',
      'total_workouts': 'Всего тренировок',
      'current_streak': 'Текущая серия',
      'settings': 'НАСТРОЙКИ',
      'app_language': 'Язык приложения',
      'data_management': 'УПРАВЛЕНИЕ ДАННЫМИ',
      'data_size': 'Размер данных',
      'export_data': 'Экспорт данных',
      'import_data': 'Импорт данных',
      'exporting_data': 'Экспорт данных...',
      'importing_data': 'Импорт данных...',
      'data_exported_successfully': 'Данные успешно экспортированы',
      'data_imported_successfully': 'Данные успешно импортированы',
      'export_error': 'Ошибка экспорта',
      'import_error': 'Ошибка импорта',
      'language_changed': 'Язык изменен. Перезапустите приложение для применения изменений.',

      // Muscle Groups
      // Muscle Categories
      'category_chest': 'Грудь',
      'category_back': 'Спина',
      'category_shoulders': 'Плечи',
      'category_biceps': 'Бицепс',
      'category_triceps': 'Трицепс',
      'category_legs': 'Ноги',

      // Detailed Muscles - Chest
      'muscle_upperChest': 'Верх груди',
      'muscle_middleChest': 'Середина груди',
      'muscle_lowerChest': 'Низ груди',
      'muscle_innerChest': 'Внутренняя часть груди',
      'muscle_outerChest': 'Внешняя часть груди',

      // Detailed Muscles - Back
      'muscle_lats': 'Широчайшие',
      'muscle_upperTraps': 'Верхние трапеции',
      'muscle_middleTraps': 'Средние трапеции',
      'muscle_lowerTraps': 'Нижние трапеции',
      'muscle_rhomboids': 'Ромбовидные',
      'muscle_teresMajor': 'Большая круглая',
      'muscle_teresMinor': 'Малая круглая',
      'muscle_infraspinatus': 'Подостная',
      'muscle_erectorSpinae': 'Разгибатели спины',
      'muscle_lowerBack': 'Поясница',

      // Detailed Muscles - Shoulders
      'muscle_frontDelts': 'Передние дельты',
      'muscle_sideDelts': 'Средние дельты',
      'muscle_rearDelts': 'Задние дельты',

      // Detailed Muscles - Arms
      'muscle_biceps': 'Бицепс',
      'muscle_longHeadTriceps': 'Длинная головка',
      'muscle_lateralHeadTriceps': 'Латеральная головка',
      'muscle_medialHeadTriceps': 'Медиальная головка',
      'muscle_forearms': 'Предплечья',

      // Detailed Muscles - Legs
      'muscle_quadriceps': 'Квадрицепс',
      'muscle_hamstrings': 'Бицепс бедра',
      'muscle_glutes': 'Ягодицы',
      'muscle_calves': 'Икры',
      'muscle_adductors': 'Приводящие',
      'muscle_abductors': 'Отводящие',

      // Detailed Muscles - Core
      'muscle_abs': 'Пресс',
      'muscle_obliques': 'Косые мышцы',

      // Progress View Toggle
      'view_mode': 'Режим отображения',
      'basic_muscles': 'Основные мышцы',
      'detailed_muscles': 'Детальные мышцы',
    },
  };
}
extension LocalizationServiceExtension on LocalizationService {
  String getFormatted(String key, Map<String, dynamic> params) {
    String text = get(key);
    params.forEach((paramKey, paramValue) {
      text = text.replaceAll('{$paramKey}', paramValue.toString());
    });
    return text;
  }
}
