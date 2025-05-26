// lib/screens/workout_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../widgets/add_set_dialog.dart';
import '../services/database_service.dart';
import 'workout_details_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with TickerProviderStateMixin {
  // Database service
  final DatabaseService _db = DatabaseService.instance;

  // Workout data
  List<Workout> _workouts = [];
  bool _isWorkoutActive = false;
  List<WorkoutExercise> _currentExercises = [];
  bool _isLoading = true;

  // Timers
  DateTime? _workoutStartTime;
  DateTime? _restStartTime;
  DateTime? _setStartTime;
  Timer? _timer;

  // Current exercise tracking
  int? _activeExerciseIndex;
  bool _isRestTimerActive = false;
  bool _isSetTimerActive = false;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _startTimer();

    // Initialize pulse animation for active timer
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final workouts = await _db.getAllWorkouts();
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading workouts: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('WORKOUTS'),
          ],
        ),
      ),
      body: _isWorkoutActive ? _buildActiveWorkout() : _buildWorkoutList(),
      floatingActionButton: !_isWorkoutActive
          ? Container(
        height: 64,
        width: 200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            onTap: _startWorkout,
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'START WORKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildWorkoutList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFDC2626),
        ),
      );
    }

    if (_workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFDC2626).withOpacity(0.1),
                    const Color(0xFF991B1B).withOpacity(0.05),
                  ],
                ),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No workouts yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first workout and crush your goals!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _workouts.length,
      itemBuilder: (context, index) {
        final workout = _workouts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A1A),
                const Color(0xFF1A1A1A).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF333333),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailsPage(workout: workout),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(workout.duration),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${workout.exercises.length} exercises',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF6B7280),
                      ),
                      onPressed: () => _deleteWorkout(workout.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteWorkout(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _db.deleteWorkout(id);
        await _loadWorkouts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting workout: $e')),
        );
      }
    }
  }

  Widget _buildActiveWorkout() {
    return Column(
      children: [
        _buildTimersSection(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._currentExercises.asMap().entries.map((entry) =>
                  _buildExerciseCard(entry.key, entry.value)
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDC2626),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MaterialButton(
                  onPressed: _showExerciseSelection,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Color(0xFFDC2626)),
                      SizedBox(width: 8),
                      Text(
                        'ADD EXERCISE',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        _buildFinishButton(),
      ],
    );
  }

  Widget _buildTimersSection() {
    final workoutDuration = _workoutStartTime != null
        ? DateTime.now().difference(_workoutStartTime!)
        : Duration.zero;

    final restDuration = _restStartTime != null && _isRestTimerActive
        ? DateTime.now().difference(_restStartTime!)
        : Duration.zero;

    final setDuration = _setStartTime != null && _isSetTimerActive
        ? DateTime.now().difference(_setStartTime!)
        : Duration.zero;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF1A1A1A).withOpacity(0),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main workout timer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFDC2626).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKOUT TIME',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(workoutDuration),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.timer,
                      color: Color(0xFFDC2626),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Rest and Set timers
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isRestTimerActive
                        ? const Color(0xFFEF4444).withOpacity(0.1)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isRestTimerActive
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF333333),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_circle_filled,
                            size: 20,
                            color: _isRestTimerActive
                                ? const Color(0xFFEF4444)
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REST',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isRestTimerActive
                                  ? const Color(0xFFEF4444)
                                  : Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(restDuration),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isRestTimerActive ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isSetTimerActive
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isSetTimerActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF333333),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            size: 20,
                            color: _isSetTimerActive
                                ? const Color(0xFF10B981)
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SET',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isSetTimerActive
                                  ? const Color(0xFF10B981)
                                  : Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(setDuration),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isSetTimerActive ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index, WorkoutExercise workoutExercise) {
    final isActive = _activeExerciseIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
            const Color(0xFFDC2626).withOpacity(0.2),
            const Color(0xFF991B1B).withOpacity(0.1),
          ]
              : [
            const Color(0xFF1A1A1A),
            const Color(0xFF1A1A1A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFFDC2626) : const Color(0xFF333333),
          width: 2,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutExercise.exercise.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          workoutExercise.exercise.muscleGroup,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive && _isSetTimerActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
            if (workoutExercise.sets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: workoutExercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${setIndex + 1}',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${set.weight} kg × ${set.reps} reps',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(set.weight * set.reps).toStringAsFixed(0)} kg',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isActive && _isSetTimerActive
                          ? LinearGradient(
                        colors: [
                          Colors.grey[800]!,
                          Colors.grey[700]!,
                        ],
                      )
                          : const LinearGradient(
                        colors: [
                          Color(0xFF10B981),
                          Color(0xFF059669),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive && !_isSetTimerActive
                          ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: MaterialButton(
                      onPressed: isActive && _isSetTimerActive
                          ? null
                          : () => _startSet(index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'START SET',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isActive && _isSetTimerActive
                          ? const LinearGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF2563EB),
                        ],
                      )
                          : LinearGradient(
                        colors: [
                          Colors.grey[800]!,
                          Colors.grey[700]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive && _isSetTimerActive
                          ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: MaterialButton(
                      onPressed: isActive && _isSetTimerActive
                          ? () => _completeSet(index, workoutExercise)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'COMPLETE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF0A0A0A).withOpacity(0),
          ],
        ),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEF4444),
              Color(0xFFDC2626),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: _finishWorkout,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.stop, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'FINISH WORKOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _workoutStartTime = DateTime.now();
      _currentExercises = [];
      _activeExerciseIndex = null;
      _isRestTimerActive = false;
      _isSetTimerActive = false;
    });
  }

  void _startSet(int exerciseIndex) {
    setState(() {
      _activeExerciseIndex = exerciseIndex;
      _isSetTimerActive = true;
      _isRestTimerActive = false;
      _setStartTime = DateTime.now();
      _restStartTime = null;
    });
  }

  void _completeSet(int exerciseIndex, WorkoutExercise workoutExercise) {
    // Get last set data if exists
    final lastSet = workoutExercise.sets.isNotEmpty
        ? workoutExercise.sets.last
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteSetDialog(
        lastWeight: lastSet?.weight,
        lastReps: lastSet?.reps,
        onComplete: (weight, reps) {
          setState(() {
            workoutExercise.sets.add(WorkoutSet(
              weight: weight,
              reps: reps,
              timestamp: DateTime.now(),
            ));

            // Start rest timer
            _isSetTimerActive = false;
            _isRestTimerActive = true;
            _setStartTime = null;
            _restStartTime = DateTime.now();
          });
        },
      ),
    );
  }

  void _showExerciseSelection() async {
    final exercises = await _db.getAllExercises();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Exercise'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF333333),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    exercise.muscleGroup,
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _currentExercises.add(WorkoutExercise(
                        exercise: exercise,
                        sets: [],
                      ));
                    });
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _finishWorkout() async {
    if (_currentExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Workout ${_formatDate(DateTime.now())}',
      date: DateTime.now(),
      exercises: _currentExercises,
      duration: DateTime.now().difference(_workoutStartTime!),
    );

    try {
      // Save to database
      await _db.createWorkout(workout);

      // Reload workouts
      await _loadWorkouts();

      setState(() {
        _isWorkoutActive = false;
        _workoutStartTime = null;
        _currentExercises = [];
        _activeExerciseIndex = null;
        _isRestTimerActive = false;
        _isSetTimerActive = false;
        _restStartTime = null;
        _setStartTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving workout: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

// Updated CompleteSetDialog with dark theme
class CompleteSetDialog extends StatefulWidget {
  final double? lastWeight;
  final int? lastReps;
  final Function(double weight, int reps) onComplete;

  const CompleteSetDialog({
    Key? key,
    this.lastWeight,
    this.lastReps,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CompleteSetDialog> createState() => _CompleteSetDialogState();
}

class _CompleteSetDialogState extends State<CompleteSetDialog> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.lastWeight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.lastReps?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'COMPLETE SET',
        style: TextStyle(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.lastWeight != null) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFDC2626).withOpacity(0.2),
                    const Color(0xFF991B1B).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFDC2626),
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  widget.onComplete(widget.lastWeight!, widget.lastReps!);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.refresh,
                        color: Color(0xFFDC2626),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SAME AS LAST SET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.lastWeight} kg × ${widget.lastReps} reps',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[700])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR ENTER MANUALLY',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: const Icon(Icons.fitness_center, color: Color(0xFFDC2626)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Reps',
              prefixIcon: const Icon(Icons.repeat, color: Color(0xFFDC2626)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MaterialButton(
            onPressed: () {
              final weight = double.tryParse(_weightController.text) ?? 0;
              final reps = int.tryParse(_repsController.text) ?? 0;

              if (weight > 0 && reps > 0) {
                widget.onComplete(weight, reps);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}