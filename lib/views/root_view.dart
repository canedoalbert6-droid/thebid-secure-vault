import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'home_view.dart';
import 'profile_view.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/app_theme.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    HomeView(),
    ProfileView(),
  ];

  final _navItems = const [
    (Icons.home_rounded,    Icons.home_outlined,      'Dashboard'),
    (Icons.person_rounded,  Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final isDark = themeVM.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _views),
      bottomNavigationBar: _buildNavBar(isDark),
    );
  }

  Widget _buildNavBar(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A2E).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 40, offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (i) => _buildNavItem(i, isDark)),
          ),
        ).animate().slideY(begin: 1.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuart),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark) {
    final isSelected = _currentIndex == index;
    final (activeIcon, inactiveIcon, label) = _navItems[index];
    const brandColor = Color(0xFF4776E6);
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black38;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: 350.ms,
            curve: Curves.easeOutQuart,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? brandColor.withValues(alpha: isDark ? 0.15 : 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? brandColor : inactiveColor,
                  size: 24,
                ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack),
                AnimatedSize(
                  duration: 350.ms,
                  curve: Curves.easeOutQuart,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              color: brandColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: 350.ms,
            width: isSelected ? 4 : 0,
            height: 4,
            decoration: BoxDecoration(
              color: brandColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
