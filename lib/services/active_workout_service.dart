// lib/services/active_workout_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

class ActiveWorkoutService extends ChangeNotifier {
  static final ActiveWorkoutService _instance = ActiveWorkoutService._internal();
  factory ActiveWorkoutService() => _instance;
  ActiveWorkoutService._internal() {
    // Загружаем сохраненное состояние при инициализации
    loadSavedState();
  }

  // Состояние тренировки
  bool _isWorkoutActive = false;
  List<WorkoutExercise> _currentExercises = [];
  DateTime? _workoutStartTime;
  DateTime? _restStartTime;
  DateTime? _setStartTime;
  int? _activeExerciseIndex;
  bool _isRestTimerActive = false;
  bool _isSetTimerActive = false;

  // Ключи для SharedPreferences
  static const String _keyIsActive = 'workout_is_active';
  static const String _keyExercises = 'workout_exercises';
  static const String _keyStartTime = 'workout_start_time';
  static const String _keyRestStartTime = 'workout_rest_start_time';
  static const String _keySetStartTime = 'workout_set_start_time';
  static const String _keyActiveIndex = 'workout_active_index';
  static const String _keyIsRestActive = 'workout_is_rest_active';
  static const String _keyIsSetActive = 'workout_is_set_active';

  // Getters
  bool get isWorkoutActive => _isWorkoutActive;
  List<WorkoutExercise> get currentExercises => _currentExercises;
  DateTime? get workoutStartTime => _workoutStartTime;
  DateTime? get restStartTime => _restStartTime;
  DateTime? get setStartTime => _setStartTime;
  int? get activeExerciseIndex => _activeExerciseIndex;
  bool get isRestTimerActive => _isRestTimerActive;
  bool get isSetTimerActive => _isSetTimerActive;

  // Вычисляемые значения
  Duration get workoutDuration {
    if (_workoutStartTime == null) return Duration.zero;
    return DateTime.now().difference(_workoutStartTime!);
  }

  Duration get restDuration {
    if (_restStartTime == null || !_isRestTimerActive) return Duration.zero;
    return DateTime.now().difference(_restStartTime!);
  }

  Duration get setDuration {
    if (_setStartTime == null || !_isSetTimerActive) return Duration.zero;
    return DateTime.now().difference(_setStartTime!);
  }

  // Загрузка сохраненного состояния
  Future<void> loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isWorkoutActive = prefs.getBool(_keyIsActive) ?? false;

      if (_isWorkoutActive) {
        // Восстанавливаем время начала тренировки
        final startTimeString = prefs.getString(_keyStartTime);
        if (startTimeString != null) {
          _workoutStartTime = DateTime.parse(startTimeString);
        }

        // Восстанавливаем упражнения
        final exercisesJson = prefs.getString(_keyExercises);
        if (exercisesJson != null) {
          final exercisesList = json.decode(exercisesJson) as List;
          _currentExercises = [];

          final db = DatabaseService.instance;

          for (var exerciseData in exercisesList) {
            final exercise = await db.getExercise(exerciseData['exerciseId']);
            if (exercise != null) {
              final sets = <WorkoutSet>[];
              for (var setData in exerciseData['sets']) {
                sets.add(WorkoutSet(
                  weight: setData['weight'].toDouble(),
                  reps: setData['reps'],
                  timestamp: DateTime.parse(setData['timestamp']),
                ));
              }

              _currentExercises.add(WorkoutExercise(
                exercise: exercise,
                sets: sets,
              ));
            }
          }
        }

        // Восстанавливаем индекс активного упражнения
        _activeExerciseIndex = prefs.getInt(_keyActiveIndex);

        // Восстанавливаем состояние таймеров
        _isRestTimerActive = prefs.getBool(_keyIsRestActive) ?? false;
        _isSetTimerActive = prefs.getBool(_keyIsSetActive) ?? false;

        // Восстанавливаем время таймеров
        final restTimeString = prefs.getString(_keyRestStartTime);
        if (restTimeString != null) {
          _restStartTime = DateTime.parse(restTimeString);
        }

        final setTimeString = prefs.getString(_keySetStartTime);
        if (setTimeString != null) {
          _setStartTime = DateTime.parse(setTimeString);
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved workout state: $e');
    }
  }

  // Сохранение состояния
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_keyIsActive, _isWorkoutActive);

      if (_isWorkoutActive) {
        // Сохраняем время начала
        if (_workoutStartTime != null) {
          await prefs.setString(_keyStartTime, _workoutStartTime!.toIso8601String());
        }

        // Сохраняем упражнения
        final exercisesList = _currentExercises.map((workoutExercise) {
          return {
            'exerciseId': workoutExercise.exercise.id,
            'sets': workoutExercise.sets.map((set) {
              return {
                'weight': set.weight,
                'reps': set.reps,
                'timestamp': set.timestamp.toIso8601String(),
              };
            }).toList(),
          };
        }).toList();

        await prefs.setString(_keyExercises, json.encode(exercisesList));

        // Сохраняем индекс активного упражнения
        if (_activeExerciseIndex != null) {
          await prefs.setInt(_keyActiveIndex, _activeExerciseIndex!);
        } else {
          await prefs.remove(_keyActiveIndex);
        }

        // Сохраняем состояние таймеров
        await prefs.setBool(_keyIsRestActive, _isRestTimerActive);
        await prefs.setBool(_keyIsSetActive, _isSetTimerActive);

        // Сохраняем время таймеров
        if (_restStartTime != null) {
          await prefs.setString(_keyRestStartTime, _restStartTime!.toIso8601String());
        } else {
          await prefs.remove(_keyRestStartTime);
        }

        if (_setStartTime != null) {
          await prefs.setString(_keySetStartTime, _setStartTime!.toIso8601String());
        } else {
          await prefs.remove(_keySetStartTime);
        }
      } else {
        // Очищаем все сохраненные данные
        await _clearSavedState();
      }
    } catch (e) {
      print('Error saving workout state: $e');
    }
  }

  // Очистка сохраненного состояния
  Future<void> _clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsActive);
    await prefs.remove(_keyExercises);
    await prefs.remove(_keyStartTime);
    await prefs.remove(_keyRestStartTime);
    await prefs.remove(_keySetStartTime);
    await prefs.remove(_keyActiveIndex);
    await prefs.remove(_keyIsRestActive);
    await prefs.remove(_keyIsSetActive);
  }

  // Методы управления тренировкой
  void startWorkout() {
    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _currentExercises = [];
    _activeExerciseIndex = null;
    _isRestTimerActive = false;
    _isSetTimerActive = false;
    _restStartTime = null;
    _setStartTime = null;
    notifyListeners();
    _saveState();
  }

  void finishWorkout() {
    _isWorkoutActive = false;
    _workoutStartTime = null;
    _currentExercises = [];
    _activeExerciseIndex = null;
    _isRestTimerActive = false;
    _isSetTimerActive = false;
    _restStartTime = null;
    _setStartTime = null;
    notifyListeners();
    _clearSavedState();
  }

  void addExercise(Exercise exercise) {
    _currentExercises.add(WorkoutExercise(
      exercise: exercise,
      sets: [],
    ));
    notifyListeners();
    _saveState();
  }

  void startSet(int exerciseIndex) {
    _activeExerciseIndex = exerciseIndex;
    _isSetTimerActive = true;
    _isRestTimerActive = false;
    _setStartTime = DateTime.now();
    _restStartTime = null;
    notifyListeners();
    _saveState();
  }

  void completeSet(int exerciseIndex, double weight, int reps) {
    if (exerciseIndex < _currentExercises.length) {
      _currentExercises[exerciseIndex].sets.add(WorkoutSet(
        weight: weight,
        reps: reps,
        timestamp: DateTime.now(),
      ));

      // Start rest timer
      _isSetTimerActive = false;
      _isRestTimerActive = true;
      _setStartTime = null;
      _restStartTime = DateTime.now();
      notifyListeners();
      _saveState();
    }
  }

  void skipRest() {
    _isRestTimerActive = false;
    _restStartTime = null;
    notifyListeners();
    _saveState();
  }

  // Получить тренировку для сохранения
  Workout createWorkout() {
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Workout ${_formatDate(DateTime.now())}',
      date: DateTime.now(),
      exercises: _currentExercises,
      duration: workoutDuration,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}