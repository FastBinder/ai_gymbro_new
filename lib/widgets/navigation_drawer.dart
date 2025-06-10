// lib/widgets/navigation_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'custom_widgets.dart';

class CustomNavigationDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavigationDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<CustomNavigationDrawer> createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Создаем анимации для каждого элемента меню с задержкой
    _itemAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= AppDimensions.tabletBreakpoint;
    final isSmallScreen = screenSize.width < AppDimensions.mobileBreakpoint;

    // Адаптивная ширина drawer
    double drawerWidth;
    if (isTablet) {
      drawerWidth = 320; // Фиксированная ширина для планшетов
    } else if (isSmallScreen) {
      drawerWidth = screenSize.width * 0.85; // 85% для маленьких экранов
    } else {
      drawerWidth = screenSize.width * 0.75; // 75% для средних экранов
    }

    // Ограничиваем максимальную ширину
    drawerWidth = drawerWidth.clamp(280.0, 400.0);

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(-10, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(isSmallScreen),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 20,
                ),
                children: [
                  _buildMenuItem(
                    index: 0,
                    icon: Icons.fitness_center,
                    title: loc.get('nav_workout'),
                    isSelected: widget.selectedIndex == 0,
                    animation: _itemAnimations[0],
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildMenuItem(
                    index: 1,
                    icon: Icons.history,
                    title: loc.get('nav_history'),
                    isSelected: widget.selectedIndex == 1,
                    animation: _itemAnimations[1],
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildMenuItem(
                    index: 2,
                    icon: Icons.list,
                    title: loc.get('nav_exercises'),
                    isSelected: widget.selectedIndex == 2,
                    animation: _itemAnimations[2],
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildMenuItem(
                    index: 3,
                    icon: Icons.analytics,
                    title: loc.get('nav_progress'),
                    isSelected: widget.selectedIndex == 3,
                    animation: _itemAnimations[3],
                    isSmallScreen: isSmallScreen,
                  ),
                  _buildMenuItem(
                    index: 4,
                    icon: Icons.person,
                    title: loc.get('nav_profile'),
                    isSelected: widget.selectedIndex == 4,
                    animation: _itemAnimations[4],
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
            _buildFooter(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed.withOpacity(0.2),
            AppColors.darkRed.withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryRed.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryRed, AppColors.darkRed],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: isSmallScreen ? 28 : 32,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  'GYMBRO',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.5,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                AdaptiveText(
                  'YOUR WORKOUT COMPANION',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 8 : 10,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    required Animation<double> animation,
    required bool isSmallScreen,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((1 - animation.value) * 50, 0),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 3 : 4,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onItemTapped(index);
                    Navigator.of(context).pop(); // Закрываем drawer
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          AppColors.primaryRed.withOpacity(0.2),
                          AppColors.darkRed.withOpacity(0.1),
                        ],
                      )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryRed
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryRed
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: AdaptiveText(
                            title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : AppColors.textPrimary,
                              letterSpacing: isSelected ? 1.2 : 0.5,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 4,
                            height: isSmallScreen ? 20 : 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          AdaptiveText(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: isSmallScreen ? 14 : 16,
                color: AppColors.primaryRed,
              ),
              SizedBox(width: isSmallScreen ? 3 : 4),
              AdaptiveText(
                'Made with Flutter',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Улучшенная анимированная кнопка меню для AppBar
class AnimatedMenuButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedMenuButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < AppDimensions.mobileBreakpoint;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryRed.withOpacity(0.1),
                  AppColors.darkRed.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPressed();
                  _controller.forward().then((_) {
                    _controller.reverse();
                  });
                },
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.menu,
                      color: AppColors.primaryRed,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}