import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'journal_test_screen.dart';
import 'report_screen.dart';
import '../services/report_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _horizontalPadding = 20.0;
  static const _sectionSpacing = 24.0;
  static const _internalSpacing = 14.0;

  int _selectedNavIndex = 0;
  bool _isLoading = false;
  late final AnimationController _shimmerController;
  final ReportController _reportController = ReportController();

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FBFA),
              Color(0xFFF3F7F5),
              Color(0xFFEAF3EF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const _NoScrollbarBehavior(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _HeaderSection(),
                          const SizedBox(height: 16),
                          const _TodayVibeCard(),
                          const SizedBox(height: _sectionSpacing),
                          _HeroCheckInButton(
                            isLoading: _isLoading,
                            onTap: _handleCheckInNow,
                          ),
                          const SizedBox(height: _sectionSpacing),
                          _ProgressSection(shimmer: _shimmerController),
                          const SizedBox(height: _sectionSpacing),
                          _DailyJournalCard(
                            onTapWrite: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const JournalTestScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: _sectionSpacing),
                          const _SectionTitle(text: 'Quick Actions'),
                          const SizedBox(height: _internalSpacing),
                          const _QuickActionsRow(),
                          const SizedBox(height: _sectionSpacing),
                          const _SectionTitle(text: 'Suggested for You'),
                          const SizedBox(height: _internalSpacing),
                          const _SuggestedRow(),
                          const SizedBox(height: _sectionSpacing),
                          const _MoodInputBar(),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _FloatingNavBar(
                  currentIndex: _selectedNavIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckInNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }
  final currentUserId = user.uid;

    setState(() => _isLoading = true);

    try {
  final report = await _reportController.getWeeklyReport(currentUserId);

      if (!mounted) {
        return;
      }

      if (report.totalEntries == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No journal data for this week')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(report: report),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load weekly report')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Alex 👋',
                style: GoogleFonts.poppins(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A45),
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome to Aether',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5F7380).withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: const [
            _RoundActionIcon(icon: Icons.notifications_none_rounded, showDot: true),
            SizedBox(width: 12),
            _RoundActionIcon(icon: Icons.more_horiz_rounded),
          ],
        ),
      ],
    );
  }
}

class _RoundActionIcon extends StatelessWidget {
  const _RoundActionIcon({required this.icon, this.showDot = false});

  final IconData icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF213640).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: const Color(0xFF25424D),
                size: 23,
              ),
            ),
            if (showDot)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3BC497),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TodayVibeCard extends StatelessWidget {
  const _TodayVibeCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth * 0.58;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF7FBF9), Color(0xFFEAF3EF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -10,
                bottom: -5,
                child: SizedBox(
                  height: 154,
                  width: 244,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 28,
                        bottom: 12,
                        child: Container(
                          width: 110,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.black.withValues(alpha: 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/cat-container.png',
                        height: 154,
                        width: 244,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFFF6FAF8),
                                  const Color(0xFFF6FAF8).withValues(alpha: 0.9),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.35, 0.75],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(0.6, 0),
                                radius: 0.8,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 16,
                bottom: 16,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Happy to see you ✨',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A3F48),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Be calm • Stay consistent • You're doing great",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.28,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _HeroCheckInButton(
                        isLoading: false,
                        onTap: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCheckInButton extends StatelessWidget {
  const _HeroCheckInButton({required this.onTap, required this.isLoading});

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF36B37E), Color(0xFF2F9E6F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F9E6F).withValues(alpha: 0.24),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isLoading ? null : onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Check In Now',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.shimmer});

  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(text: 'Your Progress'),
            Row(
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF33B286),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF33B286),
                  size: 26,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: 0.82),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF203A43).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    const _MetricTile(
                      icon: Icons.local_fire_department_rounded,
                      iconBg: Color(0xFFD2EFE5),
                      iconColor: Color(0xFF1F9D73),
                      title: '12',
                      titleSuffix: 'days',
                      subtitle: 'Current streak',
                    ),
                    Container(
                      width: 1,
                      height: 62,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      color: const Color(0xFFDCE6E2),
                    ),
                    const Expanded(
                      child: _GoalTile(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ShimmerProgressBar(
                  progress: 0.82,
                  shimmer: shimmer,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.titleSuffix,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String titleSuffix;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 170;
          final iconSize = compact ? 48.0 : 58.0;
          final iconGlyph = compact ? 26.0 : 32.0;

          return Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: iconGlyph),
              ),
              SizedBox(width: compact ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF203D48),
                        ),
                        children: [
                          TextSpan(
                            text: title,
                            style: TextStyle(
                              fontSize: compact ? 18 : 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' $titleSuffix',
                            style: TextStyle(
                              fontSize: compact ? 13.2 : 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF203D48).withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 12 : 13.2,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7E89),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 152;
        final circleSize = compact ? 58.0 : 72.0;
        final iconSize = compact ? 18.0 : 22.0;

        return Row(
          children: [
            SizedBox(
              width: circleSize,
              height: circleSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.8,
                    strokeWidth: compact ? 5 : 6,
                    backgroundColor: const Color(0xFFE2ECE8),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF33BA8B)),
                  ),
                  Icon(Icons.auto_awesome, color: const Color(0xFF33BA8B), size: iconSize),
                ],
              ),
            ),
            SizedBox(width: compact ? 6 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4/5',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 18 : 21,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF203E49),
                    ),
                  ),
                  Text(
                    'Weekly goals',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 12 : 13.2,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7E89),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShimmerProgressBar extends StatelessWidget {
  const _ShimmerProgressBar({required this.progress, required this.shimmer});

  final double progress;
  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFE1E7E4)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: AnimatedBuilder(
                animation: shimmer,
                builder: (context, child) {
                  final move = -1 + (shimmer.value * 2);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(move - 0.5, 0),
                        end: Alignment(move + 1.2, 0),
                        colors: const [
                          Color(0xFF38C092),
                          Color(0xFF5FD4A9),
                          Color(0xFF2EB184),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    const cardSize = 206.0;
    return SizedBox(
      height: cardSize,
      child: ScrollConfiguration(
        behavior: const _NoScrollbarBehavior(),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: const [
            _QuickActionCard(
              size: cardSize,
              title: 'Breathwork',
              subtitle: '2 min • Calm',
              icon: Icons.air_rounded,
              gradient: [Color(0xFFF8B270), Color(0xFFF49A5A)],
              buttonText: 'Start',
              buttonIcon: Icons.play_arrow_rounded,
              buttonTextColor: Color(0xFFF1914E),
            ),
            SizedBox(width: 14),
            _QuickActionCard(
              size: cardSize,
              title: 'Positive Energy',
              subtitle: '5 min • Uplift',
              icon: Icons.favorite_rounded,
              gradient: [Color(0xFF5BC79C), Color(0xFF2EA985)],
              buttonText: '15 min',
              buttonIcon: Icons.play_arrow_rounded,
              buttonTextColor: Color(0xFF2EA985),
            ),
            SizedBox(width: 14),
            _QuickActionCard(
              size: cardSize,
              title: 'Sleep',
              subtitle: '7 min • Relax',
              icon: Icons.nightlight_round,
              gradient: [Color(0xFF78A8E6), Color(0xFF4A86D7)],
              buttonText: 'Start',
              buttonIcon: Icons.play_arrow_rounded,
              buttonTextColor: Color(0xFF4A86D7),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.size,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.buttonText,
    required this.buttonIcon,
    required this.buttonTextColor,
  });

  final double size;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String buttonText;
  final IconData buttonIcon;
  final Color buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return _InteractiveScaleCard(
      borderRadius: 22,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 8,
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 32 / 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 30 / 2,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            buttonIcon,
                            size: 24,
                            color: buttonTextColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            buttonText,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: buttonTextColor,
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
}

class _InteractiveScaleCard extends StatefulWidget {
  const _InteractiveScaleCard({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  State<_InteractiveScaleCard> createState() => _InteractiveScaleCardState();
}

class _InteractiveScaleCardState extends State<_InteractiveScaleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? 0.97
        : _isHovered
            ? 1.01
            : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: () {},
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.23),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _DailyJournalCard extends StatelessWidget {
  const _DailyJournalCard({required this.onTapWrite});

  final VoidCallback onTapWrite;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.86),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203D48).withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFD1EFE4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF1D8968),
                size: 31,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Journal',
                    style: GoogleFonts.poppins(
                      fontSize: 19 / 1.2,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF223F4A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Reflect and grow mindfulness',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6C808C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTapWrite,
                child: Ink(
                  height: 54,
                  width: 102,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFC8DDD5),
                      width: 1.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Write',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F9873),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedRow extends StatelessWidget {
  const _SuggestedRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SuggestedCard(
            icon: Icons.headphones_rounded,
            iconBg: Color(0xFFD5EDE4),
            iconColor: Color(0xFF217F66),
            title: 'Morning Peace',
            subtitle: '8 min • Audio',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _SuggestedCard(
            icon: Icons.nightlight_round,
            iconBg: Color(0xFFE1D8F7),
            iconColor: Color(0xFF6750C7),
            title: 'Gratitude',
            subtitle: '3 min • Guide',
          ),
        ),
      ],
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  const _SuggestedCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 170;
        final dense = constraints.maxWidth < 150;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF203A42).withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              dense ? 8 : 12,
              dense ? 10 : 12,
              dense ? 8 : 12,
              dense ? 10 : 12,
            ),
            child: Row(
              children: [
                Container(
                  width: dense ? 40 : (compact ? 44 : 52),
                  height: dense ? 40 : (compact ? 44 : 52),
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(
                    icon,
                    size: dense ? 23 : (compact ? 25 : 30),
                    color: iconColor,
                  ),
                ),
                SizedBox(width: dense ? 7 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: dense ? 12.8 : (compact ? 14 : 17),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF203D49),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: dense ? 11.2 : (compact ? 12.2 : 16),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6E818D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: dense ? 34 : (compact ? 38 : 44),
                  height: dense ? 34 : (compact ? 38 : 44),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD3EEE4),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: const Color(0xFF1D9A72),
                    size: dense ? 20 : (compact ? 23 : 28),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodInputBar extends StatelessWidget {
  const _MoodInputBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3640).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF798B96),
              ),
            ),
          ),
          const Icon(
            Icons.mic_rounded,
            color: Color(0xFF26A87F),
            size: 36,
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        color: const Color(0xFFF3F7F5),
        border: Border.all(
          color: const Color(0xFFDDE8E2),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Activities',
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.trending_up_rounded,
            label: 'Growth',
            active: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            active: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2EB184) : const Color(0xFF8FA0A7);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E3A46),
      ),
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
