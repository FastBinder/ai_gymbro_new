// lib/models/exercise.dart

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? instructions;
  final List<String>? tips;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.instructions,
    this.tips,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'instructions': instructions?.join('|'),
      'tips': tips?.join('|'),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      muscleGroup: map['muscleGroup'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      instructions: map['instructions']?.split('|'),
      tips: map['tips']?.split('|'),
    );
  }
}

// Predefined exercises database
class ExerciseDatabase {
  static final List<Exercise> exercises = [
    // Chest
    const Exercise(
      id: '1',
      name: 'Barbell Bench Press',
      muscleGroup: 'Chest',
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
    const Exercise(
      id: '2',
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Chest',
      description: 'Targets upper chest muscles',
    ),
    const Exercise(
      id: '3',
      name: 'Dumbbell Flyes',
      muscleGroup: 'Chest',
      description: 'Isolation exercise for chest',
    ),

    // Back
    const Exercise(
      id: '4',
      name: 'Pull-ups',
      muscleGroup: 'Back',
      description: 'Compound exercise for lats and upper back',
    ),
    const Exercise(
      id: '5',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      description: 'Builds back thickness and strength',
    ),
    const Exercise(
      id: '6',
      name: 'Deadlift',
      muscleGroup: 'Back',
      description: 'Full body compound movement',
    ),

    // Legs
    const Exercise(
      id: '7',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      description: 'King of all leg exercises',
    ),
    const Exercise(
      id: '8',
      name: 'Romanian Deadlift',
      muscleGroup: 'Legs',
      description: 'Targets hamstrings and glutes',
    ),
    const Exercise(
      id: '9',
      name: 'Leg Press',
      muscleGroup: 'Legs',
      description: 'Machine-based leg exercise',
    ),

    // Shoulders
    const Exercise(
      id: '10',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      description: 'Builds shoulder strength and size',
    ),
    const Exercise(
      id: '11',
      name: 'Lateral Raises',
      muscleGroup: 'Shoulders',
      description: 'Isolation for side delts',
    ),

    // Arms
    const Exercise(
      id: '12',
      name: 'Barbell Curl',
      muscleGroup: 'Arms',
      description: 'Classic bicep builder',
    ),
    const Exercise(
      id: '13',
      name: 'Tricep Dips',
      muscleGroup: 'Arms',
      description: 'Compound movement for triceps',
    ),

    // Core
    const Exercise(
      id: '14',
      name: 'Plank',
      muscleGroup: 'Core',
      description: 'Isometric core exercise',
    ),
    const Exercise(
      id: '15',
      name: 'Hanging Leg Raises',
      muscleGroup: 'Core',
      description: 'Advanced ab exercise',
    ),
  ];
}