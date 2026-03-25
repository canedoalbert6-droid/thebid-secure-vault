import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../utils/app_theme.dart';
import 'components/weather_card.dart';
import 'components/activity_card.dart';
import 'components/bento_item.dart';
import 'widgets/fitness_progress_indicator.dart';
import '../utils/session_manager.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Offset mousePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionManager().startSession(context);
      final authVM = context.read<AuthViewModel>();
      if (authVM.user != null) {
        context.read<WeatherViewModel>().fetchWeatherAndSuggestions(authVM.userModel, city: "Manila");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM    = context.watch<AuthViewModel>();
    final themeVM   = context.watch<ThemeViewModel>();
    final weatherVM = context.watch<WeatherViewModel>();
    final size      = MediaQuery.of(context).size;
    final isDark    = themeVM.isDark;

    // Dynamic weather palette — fallback to brand colors
    Color primaryColor   = const Color(0xFF4776E6);
    Color secondaryColor = const Color(0xFF8E54E9);
    String weatherMood   = 'default';

    if (weatherVM.weather != null) {
      final cond = weatherVM.weather!.condition.toLowerCase();
      if (cond.contains('clear') || cond.contains('sun')) {
        primaryColor = const Color(0xFFFF8C00); secondaryColor = const Color(0xFFFFD700); weatherMood = 'sunny';
      } else if (cond.contains('rain') || cond.contains('drizzle') || cond.contains('snow')) {
        primaryColor = const Color(0xFF3A7BD5); secondaryColor = const Color(0xFF3A6073); weatherMood = 'rain';
      } else if (weatherVM.weather!.temp > 32) {
        primaryColor = const Color(0xFFE74C3C); secondaryColor = const Color(0xFFE67E22); weatherMood = 'hot';
      }
    }

    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: MouseRegion(
        onHover: (e) => setState(() => mousePos = e.localPosition),
        child: Stack(
          children: [
            _buildBackground(size, isDark, primaryColor, secondaryColor),

            SafeArea(
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                onRefresh: () async {
                  await weatherVM.fetchWeatherAndSuggestions(authVM.userModel, city: "Manila");
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // ── Sticky Header ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: _buildHeader(authVM, textColor, isDark, primaryColor)
                            .animate().fadeIn().slideY(begin: -0.15, end: 0),
                      ),
                    ),

                    if (weatherVM.isLoading)
                      SliverFillRemaining(child: _buildSkeleton(isDark))
                    else if (weatherVM.errorMessage != null)
                      SliverFillRemaining(child: _buildError(weatherVM.errorMessage!, isDark, textColor, weatherVM, authVM))
                    else ...[
                      // ── Mood badge ──────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: _buildMoodBadge(weatherMood, primaryColor, isDark)
                              .animate().fadeIn(delay: 150.ms).slideX(begin: -0.1, end: 0),
                        ),
                      ),

                      // ── Weather Card ─────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: WeatherCard(
                            weatherVM: weatherVM, isDark: isDark,
                            textColor: textColor, primaryColor: primaryColor, secondaryColor: secondaryColor,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),
                        ),
                      ),

                      // ── Bento Grid Summary ──────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: _buildBentoGrid(authVM, isDark, textColor, primaryColor)
                              .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                        ),
                      ),

                      // ── Section Header ───────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Suggested Activities', style: AppTheme.titleMd(isDark)),
                                Text('Based on your profile & weather', style: AppTheme.bodySm(isDark)),
                              ]),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.filter_list_rounded, color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${weatherVM.suggestedActivities.length} plans', style: GoogleFonts.plusJakartaSans(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            ],
                          ).animate().fadeIn(delay: 350.ms),
                        ),
                      ),

                      // ── Activity Cards ───────────────────────────────
                      if (weatherVM.suggestedActivities.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildEmptyActivities(isDark, textColor),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, idx) {
                                final activity = weatherVM.suggestedActivities[idx];
                                return ActivityCard(
                                  activity: activity,
                                  isDark: isDark,
                                  textColor: textColor,
                                  primaryColor: primaryColor,
                                ).animate()
                                 .fadeIn(delay: (400 + idx * 120).ms, duration: 400.ms)
                                 .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack);
                              },
                              childCount: weatherVM.suggestedActivities.length,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Size size, bool isDark, Color primary, Color secondary) {
    double dx = (mousePos.dx - size.width / 2) / 50;
    double dy = (mousePos.dy - size.height / 2) / 50;
    return Stack(children: [
      AnimatedPositioned(duration: 200.ms, top: size.height * 0.1 + dy, left: size.width * 0.05 + dx,
          child: AppTheme.blob(260, isDark ? primary.withValues(alpha: 0.14) : primary.withValues(alpha: 0.07))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.1, duration: 4.seconds)),
      AnimatedPositioned(duration: 200.ms, bottom: size.height * 0.1 - dy, right: size.width * 0.04 - dx,
          child: AppTheme.blob(300, isDark ? secondary.withValues(alpha: 0.12) : secondary.withValues(alpha: 0.07))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.1, end: 0.9, duration: 5.seconds)),
    ]);
  }

  Widget _buildHeader(AuthViewModel authVM, Color textColor, bool isDark, Color primary) {
    final firstName = authVM.user?.displayName?.split(' ').first ?? 'Athlete';
    final workouts  = authVM.userModel?.workoutsCompleted ?? 0;
    final streak    = authVM.userModel?.currentStreak ?? 0;

    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final greetEmoji = now.hour < 12 ? '🌅' : now.hour < 17 ? '☀️' : '🌙';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(greetEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text('$greeting, $firstName', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 2),
            ShaderMask(
              shaderCallback: (r) => AppTheme.brandGradient.createShader(r),
              child: Text('SkyFit Pro', style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
            ),
          ]),
        ),
        // Right Side: Avatar + Stats
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {}, // If you'd like to navigate to Profile later
              child: CircleAvatar(
                radius: 20,
                backgroundColor: primary.withValues(alpha: 0.2),
                backgroundImage: authVM.userModel?.profilePicture != null 
                    ? NetworkImage(authVM.userModel!.profilePicture!) 
                    : null,
                child: authVM.userModel?.profilePicture == null 
                    ? Text(firstName.isNotEmpty ? firstName[0].toUpperCase() : "U", style: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.bold))
                    : null,
              ),
            ).animate().fadeIn(delay: 150.ms),
            
            if (workouts > 0 || streak > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.25)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 14),
                    const SizedBox(width: 3),
                    Text('$streak', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: textColor)),
                  ]),
                  Text('streak', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w500)),
                ]),
              ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMoodBadge(String mood, Color primary, bool isDark) {
    final moodData = {
      'sunny':   ('☀️ Perfect outdoor day!',   Colors.orangeAccent),
      'rain':    ('🌧️ Stay warm & train inside', Colors.blueAccent),
      'hot':     ('🔥 Beat the heat wisely',    Colors.redAccent),
      'default': ('💪 Ready to crush it!',      primary),
    };
    final (label, color) = moodData[mood] ?? moodData['default']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildBentoGrid(AuthViewModel authVM, bool isDark, Color textColor, Color primary) {
    final u = authVM.userModel;
    if (u == null) return const SizedBox.shrink();

    // Calculate progress based on whether they worked out today
    final now = DateTime.now();
    final bool didWorkoutToday = u.lastWorkoutDate != null && 
      u.lastWorkoutDate!.year == now.year && 
      u.lastWorkoutDate!.month == now.month && 
      u.lastWorkoutDate!.day == now.day;
    final double workoutProgress = didWorkoutToday ? 1.0 : 0.0;

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Daily Progress Large Card
              Expanded(
                flex: 2,
                child: BentoItem(
                  title: 'Daily Goal',
                  icon: Icons.track_changes_rounded,
                  color: primary,
                  child: Center(
                    child: FitnessProgressIndicator(
                      progress: workoutProgress,
                      color: primary,
                      label: 'Activity',
                      sublabel: '${(workoutProgress * 100).toInt()}% of goal reached',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Two Vertical Smaller Cards
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: BentoItem(
                        title: 'Weight',
                        icon: Icons.monitor_weight_outlined,
                        color: Colors.blueAccent,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${u.weight ?? "--"}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                Text('kg', style: AppTheme.bodySm(isDark)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BentoItem(
                        title: 'Streak',
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${u.currentStreak}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                Text('days', style: AppTheme.bodySm(isDark)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: BentoItem(
                  title: 'Height',
                  icon: Icons.height_rounded,
                  color: Colors.greenAccent,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${u.height ?? "--"}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('cm', style: AppTheme.bodySm(isDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: BentoItem(
                  title: 'Gender',
                  icon: Icons.wc_rounded,
                  color: Colors.purpleAccent,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        u.gender ?? "--",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (u.address != null && u.address!.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: BentoItem(
              title: 'Location',
              icon: Icons.location_on_outlined,
              color: Colors.redAccent,
              child: Text(
                u.address!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyActivities(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassCard(isDark: isDark),
      child: Column(children: [
        Icon(Icons.fitness_center_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.24)),
        const SizedBox(height: 12),
        Text('No activities available', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
        Text('Pull down to refresh', style: AppTheme.bodySm(isDark)),
      ]),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
      highlightColor: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.12),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 48, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 20),
          Container(height: 32, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 16),
          Container(height: 160, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28))),
          const SizedBox(height: 32),
          Container(height: 22, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 16),
          ...List.generate(3, (i) => Container(
            height: 130, width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
          )),
        ]),
      ),
    );
  }

  Widget _buildError(String message, bool isDark, Color textColor, WeatherViewModel vm, AuthViewModel authVM) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))),
            child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          Text('Connection Error', style: AppTheme.titleMd(isDark)),
          const SizedBox(height: 8),
          Text(message, style: AppTheme.bodySm(isDark), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [BoxShadow(color: const Color(0xFF4776E6).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text('Retry', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () => vm.fetchWeatherAndSuggestions(authVM.userModel, city: "Manila"),
            ),
          ),
        ]),
      ),
    );
  }
}
