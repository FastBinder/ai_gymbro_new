// lib/models/workout.dart

import 'exercise.dart';

class WorkoutSet {
  final int reps;
  final double weight;
  final DateTime timestamp;

  WorkoutSet({
    required this.reps,
    required this.weight,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      reps: map['reps'],
      weight: map['weight'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise': exercise.toMap(),
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exercise: Exercise.fromMap(map['exercise']),
      sets: List<WorkoutSet>.from(
        map['sets'].map((s) => WorkoutSet.fromMap(s)),
      ),
    );
  }
}

class Workout {
  final String id;
  final String name;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final Duration duration;

  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.exercises,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'duration': duration.inSeconds,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      exercises: List<WorkoutExercise>.from(
        map['exercises'].map((e) => WorkoutExercise.fromMap(e)),
      ),
      duration: Duration(seconds: map['duration']),
    );
  }
}