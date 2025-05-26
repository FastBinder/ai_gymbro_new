// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../services/export_import_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  Map<String, dynamic> _stats = {
    'totalWorkouts': 0,
    'totalDuration': Duration.zero,
    'currentStreak': 0,
  };
  bool _isLoading = true;
  bool _isExporting = false;
  bool _isImporting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadStatistics();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _db.getStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final filePath = await ExportImportService.exportData();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Export Successful',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Data exported to:\n${filePath.split('/').last}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Share.shareXFiles([XFile(filePath)]);
                },
                child: const Text(
                  'Share',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isImporting = true);

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Import Data?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'This will add data from the backup file. '
                  'Existing data will NOT be deleted. '
                  'Duplicate workouts will be skipped.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Import',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await ExportImportService.importData(result.files.single.path!);
          await _loadStatistics();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Import successful!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    } finally {
      setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryRed,
          ),
        )
            : RefreshIndicator(
          color: AppColors.primaryRed,
          backgroundColor: AppColors.surface,
          onRefresh: _loadStatistics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildStats(),
                _buildActions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceLight,
            AppColors.surfaceLight.withOpacity(0),
          ],
        ),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.darkRed],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'GYM WARRIOR',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: AppColors.primaryRed,
                ),
                const SizedBox(width: 6),
                Text(
                  'LEVEL 1 BEGINNER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.fitness_center,
                  label: 'WORKOUTS',
                  value: '${_stats['totalWorkouts']}',
                  gradient: [AppColors.primaryRed, AppColors.darkRed],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  label: 'TOTAL TIME',
                  value: _formatDuration(_stats['totalDuration']),
                  gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.first.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: gradient.first,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: gradient.first,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final streakDays = _stats['currentStreak'] as int;
    final isOnFire = streakDays >= 7;

    return GymCard(
      padding: const EdgeInsets.all(24),
      gradientColors: isOnFire
          ? [
        AppColors.orange.withOpacity(0.2),
        AppColors.orange.withOpacity(0.1),
      ]
          : null,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOnFire
                    ? [AppColors.orange, const Color(0xFFEA580C)]
                    : [AppColors.primaryRed, AppColors.darkRed],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$streakDays',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isOnFire ? AppColors.orange : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DAYS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (isOnFire) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.whatshot,
                          size: 16,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ON FIRE!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          GradientButton(
            text: 'Export Data',
            icon: Icons.upload,
            onPressed: _isExporting ? () {} : _exportData,
            isLoading: _isExporting,
          ),
          const SizedBox(height: 16),
          OutlineButton(
            text: 'Import Data',
            icon: Icons.download,
            onPressed: _isImporting ? () {} : _importData,  // Изменено: пустая функция вместо null
          ),
          const SizedBox(height: 32),
          // Achievement section остается без изменений
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementBadge(
                      icon: Icons.flag,
                      label: 'First\nWorkout',
                      unlocked: _stats['totalWorkouts'] > 0,
                    ),
                    _buildAchievementBadge(
                      icon: Icons.local_fire_department,
                      label: '7 Day\nStreak',
                      unlocked: _stats['currentStreak'] >= 7,
                    ),
                    _buildAchievementBadge(
                      icon: Icons.timer,
                      label: '10 Hours\nTotal',
                      unlocked: _stats['totalDuration'].inHours >= 10,
                    ),
                    _buildAchievementBadge(
                      icon: Icons.star,
                      label: '30\nWorkouts',
                      unlocked: _stats['totalWorkouts'] >= 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Информация о приложении
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI GymBro v1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: ExportImportService.getDataSize(),
                  builder: (context, snapshot) {
                    return Text(
                      'Data: ${snapshot.data ?? 'Loading...'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAchievementBadge({
    required IconData icon,
    required String label,
    required bool unlocked,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: unlocked
                ? const LinearGradient(
              colors: [AppColors.orange, Color(0xFFEA580C)],
            )
                : null,
            color: unlocked ? null : AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: unlocked ? Colors.white : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}