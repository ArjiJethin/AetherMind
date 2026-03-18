import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Animated gradient circles background
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7DCEA0).withOpacity(0.15),
                    const Color(0xFF7DCEA0).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8FB9E8).withOpacity(0.12),
                    const Color(0xFF8FB9E8).withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFDB777).withOpacity(0.1),
                    const Color(0xFFFDB777).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F4F8),
                  Color(0xFFF5F7FA),
                  Color(0xFFFFF8F0),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main scrollable content
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCheckInButton(),
                    const SizedBox(height: 24),
                    _buildMoodCard(),
                    const SizedBox(height: 24),
                    _buildProgressSection(),
                    const SizedBox(height: 28),
                    _buildSuggestedSection(),
                    const SizedBox(height: 28),
                    _buildDailyJournal(),
                    const SizedBox(height: 24),
                    _buildMoodTracker(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Floating bottom navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: _buildBottomNav(),
                ),
              ),
            ],
          ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7DCEA0), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFFB8E6D5),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF4A9B7F),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Hi, Alex',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.waving_hand,
                      color: Color(0xFFFDB777),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'How are you feeling today?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF7C8B9C),
                  ),
                ),
              ],
            ),
          ),
          // Icons
          _buildIconButton(Icons.notifications_outlined),
          const SizedBox(width: 8),
          _buildIconButton(Icons.more_horiz),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E6ED).withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFF5C6C7C),
        size: 22,
      ),
    );
  }

  Widget _buildCheckInButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Speech balloon tail pointing upward to pet
              Positioned(
                top: -8,
                left: 20,
                child: CustomPaint(
                  painter: SpeechBalloonTail(),
                  child: const SizedBox(width: 20, height: 12),
                ),
              ),
              // Speech balloon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7DCEA0), Color(0xFF68C0A0)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF68C0A0).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Check in with me',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
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

  Widget _buildMoodCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 180,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.75),
                        Colors.white.withOpacity(0.55),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF68C0A0).withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Happy',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF68C0A0).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.sentiment_very_satisfied,
                              color: Color(0xFF68C0A0),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Be calm and stay positive',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7C8B9C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 44,
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7DCEA0), Color(0xFF68C0A0)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF68C0A0).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Start',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
            ),
            // Pet image - anchored to bottom-right corner with head overflowing outside the card
            Positioned(
              right: 10,
              bottom: 5,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Image.asset(
                      'assets/imgs/wolfie.png',
                      width: 330,
                      height: 330,
                      fit: BoxFit.contain,
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

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      'Take care of your pet by',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'completing activities',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF7C8B9C),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF68C0A0), Color(0xFF5FB3A0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF68C0A0).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '1 / 4',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF68C0A0),
                  Color(0xFF7DCEA0),
                  Color(0xFFFDB777),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF68C0A0).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Suggested for you',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildActivityCard(
                title: 'Breath\nAwareness',
                gradient: const [Color(0xFFFDB777), Color(0xFFFDA666)],
                cardIcon: Icons.air,
                icon: Icons.play_arrow_rounded,
                buttonText: 'Start',
              ),
              const SizedBox(width: 14),
              _buildActivityCard(
                title: 'Positive\nEnergy',
                gradient: const [Color(0xFF7DCEA0), Color(0xFF68C0A0)],
                cardIcon: Icons.favorite,
                icon: Icons.play_arrow_rounded,
                buttonText: '15 min',
              ),
              const SizedBox(width: 14),
              _buildActivityCard(
                title: 'Deep\nRelaxation',
                gradient: const [Color(0xFF8FB9E8), Color(0xFF7AA8DD)],
                cardIcon: Icons.bedtime,
                icon: Icons.play_arrow_rounded,
                buttonText: '19 min',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required String title,
    required List<Color> gradient,
    IconData? icon,
    IconData? cardIcon,
    required String buttonText,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and Title in row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (cardIcon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        cardIcon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Button
              Container(
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null)
                          Icon(
                            icon,
                            color: Colors.white,
                            size: 16,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          buttonText,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyJournal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Journal',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'April 18  Reflect on your...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7C8B9C),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0E6ED).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Write Now',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5C6C7C),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF5C6C7C),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mood Tracker',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Normal',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7C8B9C),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF7C8B9C)),
                        const SizedBox(width: 4),
                        Text(
                          'Happy',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF68C0A0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF68C0A0).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.sentiment_very_satisfied,
                            color: Color(0xFF68C0A0),
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Mood graph
                SizedBox(
                  height: 80,
                  child: Stack(
                    children: [
                      // Connection line
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: CustomPaint(
                          painter: MoodLinePainter(),
                          child: Container(),
                        ),
                      ),
                      // Days and dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMoodDay('Mon', 0.3),
                          _buildMoodDay('Tue', 0.5),
                          _buildMoodDay('Wed', 0.6),
                          _buildMoodDay('Thu', 0.7),
                          _buildMoodDay('Fri', 0.8),
                          _buildMoodDay('Sat', 0.9),
                          _buildMoodDay('Sun', 1.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodDay(String day, double intensity) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFFB8E6D5), const Color(0xFF7DCEA0), intensity)!,
                Color.lerp(const Color(0xFFA8DCC5), const Color(0xFF68C0A0), intensity)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF68C0A0).withOpacity(0.3 * intensity),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7C8B9C),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF68C0A0).withOpacity(0.85),
                const Color(0xFF7DCEA0).withOpacity(0.75),
                const Color(0xFFFDB777).withOpacity(0.65),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF68C0A0).withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.grid_view_rounded, 'Activities', 1),
              _buildNavItem(Icons.person_rounded, 'Profile', 2),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.65),
              size: 20,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for mood tracker line
class MoodLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB8E6D5), Color(0xFF68C0A0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [0.3, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
    final stepWidth = size.width / 6;

    for (int i = 0; i < points.length; i++) {
      final x = i * stepWidth;
      final y = size.height * (1 - points[i] * 0.6);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for speech balloon tail
class SpeechBalloonTail extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7DCEA0), Color(0xFF68C0A0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
