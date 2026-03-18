import 'dart:ui' show ImageFilter, clampDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onStartJourney,
    this.onExistingAccount,
    this.onPrivacyPolicy,
    this.onTermsOfService,
    this.onPsychiatristLogin,
  });

  final VoidCallback? onStartJourney;
  final VoidCallback? onExistingAccount;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onPsychiatristLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _backgroundTop = Color(0xFFB8D3CC);
  static const _backgroundMid = Color(0xFF87AAA2);
  static const _backgroundBottom = Color(0xFF4F6E69);
  static const _buttonStart = Color(0xFF2D726B);
  static const _buttonEnd = Color(0xFF184F4B);
  static const _softWhite = Color(0xFFF7FFFB);

  late final AnimationController _controller;
  late final Animation<double> _floatOffset;
  late final Animation<double> _glowStrength;
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _termsRecognizer;
  TapGestureRecognizer? _psychiatristRecognizer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -30, end: -14).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowStrength = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyPolicy;
    _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsOfService;
    _psychiatristRecognizer = TapGestureRecognizer()..onTap = _handlePsychiatristLogin;

    // Precache images after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/imgs/intro-bg.png'),
        context,
      ).catchError((e) {
        debugPrint('Failed to precache intro-bg.png: $e');
      });
      precacheImage(
        const AssetImage('assets/imgs/intro-page-pet.png'),
        context,
      ).catchError((e) {
        debugPrint('Failed to precache intro-page-pet.png: $e');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    _psychiatristRecognizer?.dispose();
    super.dispose();
  }

  void _handleStartJourney() {
    if (widget.onStartJourney != null) {
      widget.onStartJourney!.call();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _handleExistingAccount() {
    widget.onExistingAccount?.call();
  }

  void _handlePrivacyPolicy() {
    widget.onPrivacyPolicy?.call();
  }

  void _handleTermsOfService() {
    widget.onTermsOfService?.call();
  }

  void _handlePsychiatristLogin() {
    widget.onPsychiatristLogin?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundBottom, _backgroundMid, _backgroundTop],
          ),
        ),
        child: Stack(
          children: [
            // Background image with fade overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: const _FullScreenBackgroundImage(),
              ),
            ),

            // Ambient decorations
            const Positioned.fill(child: _AmbientBackdrop()),

            // Content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final petSize = clampDouble(width * 1.3, 400, 580);
                  final titleSize = clampDouble(width * 0.072, 28, 35);
                  final bodySize = clampDouble(width * 0.033, 13, 14.5);
                  final buttonHeight = clampDouble(height * 0.075, 56, 60);
                  final horizontalPadding = clampDouble(width * 0.075, 24, 34);
                  final contentMaxWidth = clampDouble(width * 0.9, 0, 430);

                  // Calculate position to center pet in background image (50% of full screen)
                  final fullScreenHeight = MediaQuery.of(context).size.height;
                  final bgImageHeight = fullScreenHeight * 0.5;
                  final topSectionHeight = bgImageHeight - MediaQuery.of(context).padding.top;
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        // Top section - pet only (centered in background image)
                        SizedBox(
                          height: topSectionHeight,
                          child: Center(
                            child: SizedBox(
                              height: petSize * 0.55,
                              child: _PetOverlay(
                                petSize: petSize,
                                floatOffset: _floatOffset,
                                glowStrength: _glowStrength,
                              ),
                            ),
                          ),
                        ),
                        // Middle section - quote
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: contentMaxWidth),
                            child: Text(
                              'Aether grows with you,\none step at a time.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                letterSpacing: -0.3,
                                color: _softWhite.withValues(alpha: 0.92),
                              ),
                            ),
                          ),
                        ),
                        // Flexible spacer
                        Expanded(
                          child: Container(),
                        ),
                        // Bottom section - buttons and policies
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PrimaryActionButton(
                                height: buttonHeight,
                                onTap: _handleStartJourney,
                              ),
                              const SizedBox(height: 14),
                              _SecondaryActionButton(
                                height: buttonHeight,
                                onTap: _handleExistingAccount,
                              ),
                              SizedBox(height: height * 0.02),
                              Text.rich(
                                TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: bodySize,
                                    height: 1.55,
                                    color: _softWhite.withValues(alpha: 0.7),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'By continuing, you agree to our ',
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      recognizer: _privacyRecognizer,
                                      style: GoogleFonts.inter(
                                        fontSize: bodySize,
                                        height: 1.55,
                                        fontWeight: FontWeight.w600,
                                        color: _softWhite.withValues(alpha: 0.9),
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      recognizer: _termsRecognizer,
                                      style: GoogleFonts.inter(
                                        fontSize: bodySize,
                                        height: 1.55,
                                        fontWeight: FontWeight.w600,
                                        color: _softWhite.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (widget.onPsychiatristLogin != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text.rich(
                                    TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: bodySize * 0.85,
                                        height: 1.4,
                                        color: _softWhite.withValues(alpha: 0.45),
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Are you a ',
                                        ),
                                        TextSpan(
                                          text: 'professional?',
                                          recognizer: _psychiatristRecognizer,
                                          style: GoogleFonts.inter(
                                            fontSize: bodySize * 0.85,
                                            height: 1.4,
                                            fontWeight: FontWeight.w700,
                                            color: _softWhite.withValues(alpha: 0.75),
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                      ],
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

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -60,
          child: _GlowOrb(
            size: 280,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          top: 120,
          right: -80,
          child: _GlowOrb(
            size: 260,
            color: const Color(0xFFDFF9F1).withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -50,
          child: _GlowOrb(
            size: 340,
            color: const Color(0xFF2A5A55).withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _FullScreenBackgroundImage extends StatelessWidget {
  const _FullScreenBackgroundImage();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.5;
    
    // Color-synced background - sampled from image bottom tones
    final imageBottomVeryLight = const Color(0xFF9AC4BD);  // very light fade
    final imageBottomLight = const Color(0xFF8DB8B1);      // light from image
    final imageBottomMid = const Color(0xFF7BA9A0);        // mid tone
    final bgTransition = const Color(0xFF87AAA2);          // transition to background
    
    return Stack(
      children: [
        // Color-synced background gradient (matches image bottom colors)
        Container(
          width: double.infinity,
          height: imageHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                imageBottomVeryLight.withValues(alpha: 0.7),
                imageBottomLight,
                imageBottomMid,
                bgTransition,
              ],
              stops: const [0.0, 0.45, 0.7, 1.0],
            ),
          ),
        ),
        
        // Image with U-shaped clip and extended smooth fade
        ClipPath(
          clipper: _UShapedClipper(imageHeight),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              // Extended soft fade spanning ~250-300px
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,                                  // 0.0 - fully visible
                  Colors.white,                                  // 0.55 - still fully visible
                  Colors.white.withValues(alpha: 0.88),         // 0.63 - very subtle fade
                  Colors.white.withValues(alpha: 0.6),          // 0.75 - noticeable fade
                  Colors.white.withValues(alpha: 0.25),         // 0.87 - mostly faded
                  Colors.transparent,                            // 1.0 - fully transparent
                ],
                stops: const [0.0, 0.55, 0.63, 0.75, 0.87, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/imgs/intro-bg.png',
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Micro feather layer - extremely subtle edge softening (5-10% opacity)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 50,  // Very thin feather band at edge
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  bgTransition.withValues(alpha: 0.06),  // Extremely subtle
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UShapedClipper extends CustomClipper<Path> {
  final double imageHeight;
  
  _UShapedClipper(this.imageHeight);

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    
    // Start at top-left
    path.lineTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, imageHeight * 0.7); // Straight down to 70% of image
    
    // Bottom-right curve (quadratic Bezier for smooth U shape)
    final curveControlX = width;
    final curveControlY = imageHeight;
    final curveEndX = width * 0.5; // Center
    final curveEndY = imageHeight * 0.95;
    
    path.quadraticBezierTo(curveControlX, curveControlY, curveEndX, curveEndY);
    
    // Bottom-left curve (quadratic Bezier mirror)
    final curveControlX2 = 0.0;
    final curveControlY2 = imageHeight;
    
    path.quadraticBezierTo(curveControlX2, curveControlY2, 0.0, imageHeight * 0.7);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_UShapedClipper oldClipper) {
    return oldClipper.imageHeight != imageHeight;
  }
}

class _PetOverlay extends StatefulWidget {
  const _PetOverlay({
    required this.petSize,
    required this.floatOffset,
    required this.glowStrength,
  });

  final double petSize;
  final Animation<double> floatOffset;
  final Animation<double> glowStrength;

  @override
  State<_PetOverlay> createState() => _PetOverlayState();
}

class _PetOverlayState extends State<_PetOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pet with floating, glow, and pulse animation
        AnimatedBuilder(
          animation: Listenable.merge(
              [widget.floatOffset, widget.glowStrength, _scaleAnimation]),
          builder: (context, child) {
            final scale = _scaleAnimation.value;
            return Transform.translate(
              offset: Offset(0, widget.floatOffset.value),
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pet image
                    Image.asset(
                      'assets/imgs/intro-page-pet.png',
                      width: widget.petSize,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _LoginScreenState._buttonStart.withValues(alpha: 0.85),
                _LoginScreenState._buttonEnd.withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFB4FFF1).withValues(alpha: 0.25),
                blurRadius: 18,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: height,
                child: Center(
                  child: Text(
                    'Start Journey',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: Colors.white.withValues(alpha: 0.96),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.white.withValues(alpha: 0.12),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
