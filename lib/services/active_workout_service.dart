// lib/services/active_workout_service.dart

import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class ActiveWorkoutService extends ChangeNotifier {
  static final ActiveWorkoutService _instance = ActiveWorkoutService._internal();
  factory ActiveWorkoutService() => _instance;
  ActiveWorkoutService._internal();

  // Состояние тренировки
  bool _isWorkoutActive = false;
  List<WorkoutExercise> _currentExercises = [];
  DateTime? _workoutStartTime;
  DateTime? _restStartTime;
  DateTime? _setStartTime;
  int? _activeExerciseIndex;
  bool _isRestTimerActive = false;
  bool _isSetTimerActive = false;

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
  }

  void addExercise(Exercise exercise) {
    _currentExercises.add(WorkoutExercise(
      exercise: exercise,
      sets: [],
    ));
    notifyListeners();
  }

  void startSet(int exerciseIndex) {
    _activeExerciseIndex = exerciseIndex;
    _isSetTimerActive = true;
    _isRestTimerActive = false;
    _setStartTime = DateTime.now();
    _restStartTime = null;
    notifyListeners();
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
    }
  }

  void skipRest() {
    _isRestTimerActive = false;
    _restStartTime = null;
    notifyListeners();
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