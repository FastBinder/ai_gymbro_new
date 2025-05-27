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
      'save_exercise': 'Save Exercise',
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

      // Muscle Groups
      'muscle_chest': 'Chest',
      'muscle_back': 'Back',
      'muscle_shoulders': 'Shoulders',
      'muscle_biceps': 'Biceps',
      'muscle_triceps': 'Triceps',
      'muscle_forearms': 'Forearms',
      'muscle_abs': 'Abs',
      'muscle_obliques': 'Obliques',
      'muscle_quadriceps': 'Quadriceps',
      'muscle_hamstrings': 'Hamstrings',
      'muscle_glutes': 'Glutes',
      'muscle_calves': 'Calves',
      'muscle_traps': 'Traps',
      'muscle_lats': 'Lats',
      'muscle_middle_back': 'Middle Back',
      'muscle_lower_back': 'Lower Back',
      'muscle_front_delts': 'Front Delts',
      'muscle_side_delts': 'Side Delts',
      'muscle_rear_delts': 'Rear Delts',
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
      'start_set': 'НАЧАТЬ ПОДХОД',
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
      'save_exercise': 'Сохранить упражнение',
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
      'muscle_chest': 'Грудь',
      'muscle_back': 'Спина',
      'muscle_shoulders': 'Плечи',
      'muscle_biceps': 'Бицепс',
      'muscle_triceps': 'Трицепс',
      'muscle_forearms': 'Предплечья',
      'muscle_abs': 'Пресс',
      'muscle_obliques': 'Косые мышцы',
      'muscle_quadriceps': 'Квадрицепс',
      'muscle_hamstrings': 'Бицепс бедра',
      'muscle_glutes': 'Ягодицы',
      'muscle_calves': 'Икры',
      'muscle_traps': 'Трапеция',
      'muscle_lats': 'Широчайшие',
      'muscle_middle_back': 'Середина спины',
      'muscle_lower_back': 'Поясница',
      'muscle_front_delts': 'Передние дельты',
      'muscle_side_delts': 'Средние дельты',
      'muscle_rear_delts': 'Задние дельты',
    },
  };
}