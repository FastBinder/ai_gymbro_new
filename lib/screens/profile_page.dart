// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
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
  String _selectedLanguage = 'en'; // По умолчанию английский

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _loadDataSize();
    _loadLanguagePreference();
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

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('app_language') ?? 'en';
    });
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    setState(() {
      _selectedLanguage = language;
    });

    // Показываем сообщение о необходимости перезапуска
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == 'ru'
              ? 'Язык изменен. Перезапустите приложение для применения изменений.'
              : 'Language changed. Please restart the app to apply changes.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              color: AppColors.primaryRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedLanguage == 'ru' ? 'ПРОФИЛЬ' : 'PROFILE',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildStatisticsSection() {
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
                _selectedLanguage == 'ru' ? 'СТАТИСТИКА' : 'STATISTICS',
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
              _selectedLanguage == 'ru' ? 'Всего тренировок' : 'Total Workouts',
              _statistics!['totalWorkouts'].toString(),
              Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              _selectedLanguage == 'ru' ? 'Общее время' : 'Total Time',
              _formatDuration(_statistics!['totalDuration']),
              Icons.timer,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              _selectedLanguage == 'ru' ? 'Текущая серия' : 'Current Streak',
              '${_statistics!['currentStreak']} ${_selectedLanguage == 'ru' ? 'дней' : 'days'}',
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
                _selectedLanguage == 'ru' ? 'НАСТРОЙКИ' : 'SETTINGS',
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
                _selectedLanguage == 'ru' ? 'Язык приложения' : 'App Language',
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLanguageOption(
                      'English',
                      'en',
                      '🇬🇧',
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

  Widget _buildLanguageOption(String title, String languageCode, String flag) {
    final isSelected = _selectedLanguage == languageCode;

    return GestureDetector(
      onTap: () => _saveLanguagePreference(languageCode),
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
                _selectedLanguage == 'ru' ? 'УПРАВЛЕНИЕ ДАННЫМИ' : 'DATA MANAGEMENT',
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
                    _selectedLanguage == 'ru'
                        ? 'Размер данных: $_dataSize'
                        : 'Data size: $_dataSize',
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
            text: _selectedLanguage == 'ru' ? 'Экспорт данных' : 'Export Data',
            icon: Icons.upload,
            onPressed: _exportData,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          OutlineButton(
            text: _selectedLanguage == 'ru' ? 'Импорт данных' : 'Import Data',
            icon: Icons.download,
            onPressed: _importData,
            borderColor: AppColors.primaryRed,
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
                  _selectedLanguage == 'ru' ? 'Экспорт данных...' : 'Exporting data...',
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
          content: Text(
            _selectedLanguage == 'ru'
                ? 'Данные успешно экспортированы'
                : 'Data exported successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'ru'
                ? 'Ошибка экспорта: $e'
                : 'Export error: $e',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _importData() async {
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
                    _selectedLanguage == 'ru' ? 'Импорт данных...' : 'Importing data...',
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
            content: Text(
              _selectedLanguage == 'ru'
                  ? 'Данные успешно импортированы'
                  : 'Data imported successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'ru'
                ? 'Ошибка импорта: $e'
                : 'Import error: $e',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}${_selectedLanguage == 'ru' ? 'ч' : 'h'} ${minutes}${_selectedLanguage == 'ru' ? 'м' : 'm'}';
    } else {
      return '${minutes}${_selectedLanguage == 'ru' ? 'м' : 'm'}';
    }
  }
}