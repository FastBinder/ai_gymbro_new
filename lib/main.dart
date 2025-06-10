// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/workout_page.dart';
import 'screens/exercises_page.dart';
import 'screens/progress_page.dart';
import 'screens/profile_page.dart';
import 'services/localization_service.dart';
import 'services/active_workout_service.dart';
import 'widgets/navigation_drawer.dart';
import 'screens/workout_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка системного UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Инициализация локализации
  final localizationService = LocalizationService();
  await localizationService.loadLanguage();

  // Инициализация сервиса тренировки
  final workoutService = ActiveWorkoutService();

  // Ждем загрузку сохраненного состояния
  await workoutService.loadSavedState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localizationService),
        ChangeNotifierProvider.value(value: workoutService),
      ],
      child: const GymTrackerApp(),
    ),
  );
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI GymBro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFDC2626), // Red-600
        scaffoldBackgroundColor: const Color(0xFF000000),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFDC2626),
          secondary: Color(0xFF991B1B),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF000000),
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFDC2626),
          foregroundColor: Colors.white,
          elevation: 8,
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1A1A1A),
          selectedColor: const Color(0xFFDC2626),
          disabledColor: const Color(0xFF333333),
          labelStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF333333)),
          ),
        ),

        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const WorkoutPage(),
    const WorkoutHistoryPage(),
    const ExercisesPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Добавляем observer для отслеживания жизненного цикла приложения
    WidgetsBinding.instance.addObserver(this);

    // Если есть активная тренировка, переключаемся на страницу тренировки
    final workoutService = context.read<ActiveWorkoutService>();
    if (workoutService.isWorkoutActive) {
      _selectedIndex = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Сохраняем состояние при сворачивании приложения
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final workoutService = context.read<ActiveWorkoutService>();
      if (workoutService.isWorkoutActive) {
        // Состояние уже автоматически сохраняется в ActiveWorkoutService
        print('App paused/detached - workout state saved');
      }
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      endDrawer: CustomNavigationDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onDestinationSelected,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPageIcon(_selectedIndex),
              color: const Color(0xFFDC2626),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              _getPageTitle(_selectedIndex, loc),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          AnimatedMenuButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        // Убираем стандартную кнопку drawer
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
            // Page content
            _pages[_selectedIndex],
          ],
        ),
      ),
    );
  }

  IconData _getPageIcon(int index) {
    switch (index) {
      case 0:
        return Icons.fitness_center;
      case 1:
        return Icons.history;
      case 2:
        return Icons.list;
      case 3:
        return Icons.analytics;
      case 4:
        return Icons.person;
      default:
        return Icons.fitness_center;
    }
  }

  String _getPageTitle(int index, LocalizationService loc) {
    switch (index) {
      case 0:
        return loc.get('nav_workout');
      case 1:
        return loc.get('nav_history');
      case 2:
        return loc.get('nav_exercises');
      case 3:
        return loc.get('nav_progress');
      case 4:
        return loc.get('nav_profile');
      default:
        return '';
    }
  }
}