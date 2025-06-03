// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/export_import_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseService _db = DatabaseService.instance;
  Map<String, dynamic>? _statistics;
  String _dataSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _loadDataSize();
  }

  Future<void> _loadStatistics() async {
    final stats = await _db.getStatistics();
    setState(() {
      _statistics = stats;
    });
  }

  Future<void> _loadDataSize() async {
    final size = await ExportImportService.getDataSize();
    setState(() {
      _dataSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildDataManagementSection(),
        ],
      ),
    );
  }


  Widget _buildStatisticsSection() {
    final loc = context.watch<LocalizationService>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed.withOpacity(0.1),
            AppColors.darkRed.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                loc.get('statistics'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_statistics != null) ...[
            _buildStatItem(
              loc.get('total_workouts'),
              _statistics!['totalWorkouts'].toString(),
              Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              loc.get('total_time'),
              _formatDuration(_statistics!['totalDuration'], loc),
              Icons.timer,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              loc.get('current_streak'),
              '${_statistics!['currentStreak']} ${loc.get('days')}',
              Icons.local_fire_department,
            ),
          ] else
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final loc = context.watch<LocalizationService>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                loc.get('settings'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Language Setting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.get('app_language'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      'Русский',
                      'ru',
                      '🇷🇺',
                      loc,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLanguageOption(
                      'English',
                      'en',
                      '🇬🇧',
                      loc,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, String languageCode, String flag, LocalizationService loc) {
    final isSelected = loc.currentLanguage == languageCode;

    return GestureDetector(
      onTap: () async {
        await loc.setLanguage(languageCode);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.get('language_changed')),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withOpacity(0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.primaryRed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    final loc = context.watch<LocalizationService>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                loc.get('data_management'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${loc.get('data_size')}: $_dataSize',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: loc.get('export_data'),
            icon: Icons.upload,
            onPressed: _exportData,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          OutlineButton(
            text: loc.get('import_data'),
            icon: Icons.download,
            onPressed: _importData,
            borderColor: AppColors.primaryRed,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryRed,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
    final loc = context.read<LocalizationService>();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryRed,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.get('exporting_data'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final filePath = await ExportImportService.exportData();
      Navigator.of(context).pop();

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'AI GymBro Backup',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('data_exported_successfully')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('export_error') + ': $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _importData() async {
    final loc = context.read<LocalizationService>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.get('importing_data'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await ExportImportService.importData(result.files.single.path!);
        Navigator.of(context).pop();

        await _loadStatistics();
        await _loadDataSize();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.get('data_imported_successfully')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('import_error') + ': $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  String _formatDuration(Duration duration, LocalizationService loc) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}${loc.currentLanguage == 'ru' ? 'ч' : 'h'} ${minutes}${loc.currentLanguage == 'ru' ? 'м' : 'm'}';
    } else {
      return '${minutes}${loc.currentLanguage == 'ru' ? 'м' : 'm'}';
    }
  }
}