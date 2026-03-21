import 'dart:ui' show ImageFilter, clampDouble;
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'psychiatrist_screen.dart';

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
  with TickerProviderStateMixin {
  static const _backgroundTop = Color(0xFFB8D3CC);
  static const _backgroundMid = Color(0xFF87AAA2);
  static const _backgroundBottom = Color(0xFF4F6E69);
  static const _buttonStart = Color(0xFF2D726B);
  static const _buttonEnd = Color(0xFF184F4B);
  static const _softWhite = Color(0xFFF7FFFB);

  late final AnimationController _controller;
  late final AnimationController _screenTransitionController;
  late final Animation<double> _floatOffset;
  late final Animation<double> _glowStrength;
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _termsRecognizer;
  TapGestureRecognizer? _psychiatristRecognizer;

  String _currentScreen = 'main'; // 'main', 'signup', 'login', 'professional'

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _screenTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: 1,
    );
    _floatOffset = Tween<double>(begin: -30, end: -14).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowStrength = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyPolicy;
    _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsOfService;
    _psychiatristRecognizer =
        TapGestureRecognizer()..onTap = _handlePsychiatristLogin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/imgs/intro-p-pet.png'),
        context,
      ).catchError((e) {
        debugPrint('Failed to precache intro-page-pet.png: $e');
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    _screenTransitionController.dispose();
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    _psychiatristRecognizer?.dispose();
    super.dispose();
  }

  Future<void> _switchToScreen(String screen) async {
    if (_currentScreen == screen) {
      return;
    }

    await _screenTransitionController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInCubic,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentScreen = screen;
    });

    _screenTransitionController.forward(from: 0);
  }

  void _handleStartJourney() {
    _switchToScreen('signup');
  }

  void _handleExistingAccount() {
    _switchToScreen('login');
  }

  void _handlePsychiatristLogin() {
    _switchToScreen('professional');
  }

  void _backToMainScreen() {
    _switchToScreen('main');
  }

  void _handlePrivacyPolicy() {
    if (widget.onPrivacyPolicy != null) {
      widget.onPrivacyPolicy!.call();
    } else {
      _showPlaceholderDialog(
        'Privacy Policy',
        'This is our Privacy Policy placeholder text.\n\nYour privacy is important to us. We collect and process personal data in accordance with applicable regulations.',
      );
    }
  }

  void _handleTermsOfService() {
    if (widget.onTermsOfService != null) {
      widget.onTermsOfService!.call();
    } else {
      _showPlaceholderDialog(
        'Terms of Service',
        'This is our Terms of Service placeholder text.\n\nBy using our service, you agree to comply with these terms and conditions.',
      );
    }
  }

  void _showPlaceholderDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.inter()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  TextStyle _buildBrandTitleStyle(double titleSize) {
    return TextStyle(
      fontFamily: 'Doto',
      fontSize: titleSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: const Color(0xFF244A44),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenTransition = CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeOutCubic,
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AnimatedTopBottomGradient()),
          Stack(
          children: [
            // Ambient decorations
            const Positioned.fill(child: _AmbientBackdrop()),

            if (_currentScreen == 'main')
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final titleSize = clampDouble(width * 0.09, 28, 32);
                    final subtitleSize = clampDouble(width * 0.042, 14, 16);
                    final bodySize = clampDouble(width * 0.033, 12.5, 13.2);
                    final buttonHeight = clampDouble(
                      constraints.maxHeight * 0.075,
                      52,
                      56,
                    );
                    final petFrameHeight = clampDouble(
                      constraints.maxHeight * 0.34,
                      224,
                      310,
                    );
                    final petSize = clampDouble(width * 1.06, 330, 460);
                    final horizontalPadding = clampDouble(width * 0.06, 20, 24);
                    final safeBottom = mediaQuery.padding.bottom;

                    return Stack(
                      children: [
                        Positioned(
                          top: clampDouble(constraints.maxHeight * 0.055, 34, 54),
                          left: 20,
                          right: 20,
                          child: Column(
                            children: [
                              Text(
                                'AETHER',
                                textAlign: TextAlign.center,
                                style: _buildBrandTitleStyle(titleSize),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Aether grows with you\nthrough every small step',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.38,
                                  color: const Color.fromARGB(255, 69, 123, 113),
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x66121816),
                                      offset: Offset(0, 1),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: constraints.maxHeight * 0.29,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              height: petFrameHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: petFrameHeight,
                                    child: _PetOverlay(
                                      petSize: petSize,
                                      floatOffset: _floatOffset,
                                      glowStrength: _glowStrength,
                                    ),
                                  ),
                                ],
                                ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDE7E1),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.24),
                                    const Color(0xFFDDE7E1),
                                  ],
                                  stops: const [0.0, 0.24],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  22,
                                  horizontalPadding,
                                  22 + safeBottom,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 450),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
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
                                        const SizedBox(height: 20),
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: bodySize,
                                              height: 1.55,
                                              color: const Color(0xFF365A54).withValues(alpha: 0.72),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'By continuing, you agree to our ',
                                              ),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                recognizer: _privacyRecognizer,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: bodySize,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF274A45).withValues(alpha: 0.92),
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Terms of Service',
                                                recognizer: _termsRecognizer,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: bodySize,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF274A45).withValues(alpha: 0.92),
                                                ),
                                              ),
                                              const TextSpan(text: '. Are you a '),
                                              TextSpan(
                                                text: 'professional?',
                                                recognizer: _psychiatristRecognizer,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: bodySize,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF274A45).withValues(alpha: 0.92),
                                                ),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              Positioned(
                top: mediaQuery.padding.top,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: (screenHeight * 0.5) - mediaQuery.padding.top,
                  child: AnimatedBuilder(
                    animation: screenTransition,
                    builder: (context, child) {
                      final t = screenTransition.value;
                      return Opacity(
                        opacity: 0.35 + (t * 0.65),
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * 44),
                          child: Transform.scale(
                            scale: 0.82 + (t * 0.18),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: SizedBox(
                        height: clampDouble(mediaQuery.size.width * 0.95, 230, 320),
                        child: _PetOverlay(
                          petSize: clampDouble(mediaQuery.size.width * 1.05, 300, 420),
                          floatOffset: _floatOffset,
                          glowStrength: _glowStrength,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentScreen != 'main')
              AnimatedBuilder(
                animation: screenTransition,
                builder: (context, child) {
                  final t = screenTransition.value;
                  final top = (screenHeight * 0.72) - ((screenHeight * 0.22) * t);

                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.84 + (t * 0.16),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: _BottomAttachedAuthForm(
                          currentScreen: _currentScreen,
                          onBack: _backToMainScreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedTopBottomGradient extends StatefulWidget {
  const _AnimatedTopBottomGradient();

  @override
  State<_AnimatedTopBottomGradient> createState() => _AnimatedTopBottomGradientState();
}

class _AnimatedTopBottomGradientState extends State<_AnimatedTopBottomGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = math.sin(_controller.value * 2 * math.pi);
        final drift = phase * 0.09;
        final crest = (0.70 - drift).clamp(0.58, 0.78);

        return Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7FFFB),
                    _LoginScreenState._backgroundTop,
                    _LoginScreenState._backgroundMid,
                    _LoginScreenState._backgroundBottom,
                  ],
                  stops: [0.0, 0.42, 0.78, 1.0],
                ),
              ),
              child: SizedBox.expand(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFFFFFFF).withValues(alpha: 0.055),
                    const Color(0xFF6D928B).withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                  stops: [
                    (crest - 0.22).clamp(0.0, 1.0),
                    (crest - 0.08).clamp(0.0, 1.0),
                    (crest + 0.08).clamp(0.0, 1.0),
                    (crest + 0.24).clamp(0.0, 1.0),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ],
        );
      },
    );
  }
}

class _MidScreenReadabilityGradient extends StatelessWidget {
  const _MidScreenReadabilityGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.14),
            ],
            stops: const [0.0, 0.47, 0.62, 1.0],
          ),
        ),
      ),
    );
  }
}

class _BottomAttachedAuthForm extends StatelessWidget {
  const _BottomAttachedAuthForm({
    required this.currentScreen,
    required this.onBack,
  });

  final String currentScreen;
  final VoidCallback onBack;

  double _estimatedContentHeight() {
    switch (currentScreen) {
      case 'signup':
        return 420;
      case 'professional':
        return 420;
      case 'login':
      default:
        return 300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final horizontalPadding = clampDouble(width * 0.06, 20, 24);
    final titleSize = clampDouble(width * 0.075, 29, 37);
    final bodySize = clampDouble(width * 0.035, 13.5, 15);
    const buttonHeight = 52.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final safeBottom = mediaQuery.padding.bottom;
          final availableHeight = constraints.maxHeight - safeBottom;
          final estimatedContentHeight = _estimatedContentHeight();
          final balancedInset = ((availableHeight - estimatedContentHeight) / 2)
              .clamp(20.0, 36.0)
              .toDouble();

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFDDE7E1),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  const Color(0xFFDDE7E1),
                ],
                stops: const [0.0, 0.24],
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        balancedInset,
                        horizontalPadding,
                        balancedInset + safeBottom,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: currentScreen == 'signup'
                              ? _SignUpForm(
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  buttonHeight: buttonHeight,
                                  onBack: onBack,
                                )
                              : currentScreen == 'login'
                              ? _LoginForm(
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  buttonHeight: buttonHeight,
                                  onBack: onBack,
                                )
                              : _ProfessionalForm(
                                  titleSize: titleSize,
                                  bodySize: bodySize,
                                  buttonHeight: buttonHeight,
                                  onBack: onBack,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.11),
                            Colors.white.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomAttachedMainPanel extends StatelessWidget {
  const _BottomAttachedMainPanel({
    required this.buttonHeight,
    required this.bodySize,
    required this.onStartJourney,
    required this.onExistingAccount,
    required this.privacyRecognizer,
    required this.termsRecognizer,
    required this.psychiatristRecognizer,
  });

  final double buttonHeight;
  final double bodySize;
  final VoidCallback onStartJourney;
  final VoidCallback onExistingAccount;
  final TapGestureRecognizer privacyRecognizer;
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer? psychiatristRecognizer;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final horizontalPadding = clampDouble(width * 0.06, 20, 24);
    final safeBottom = mediaQuery.padding.bottom;
    const verticalInset = 22.0;

    return Stack(
      children: [
        SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalInset,
              horizontalPadding,
              verticalInset + safeBottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PrimaryActionButton(
                      height: buttonHeight,
                      onTap: onStartJourney,
                    ),
                    const SizedBox(height: 14),
                    _SecondaryActionButton(
                      height: buttonHeight,
                      onTap: onExistingAccount,
                    ),
                    const SizedBox(height: 22),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: bodySize,
                          height: 1.55,
                          color: _LoginScreenState._softWhite.withValues(alpha: 0.7),
                        ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            recognizer: privacyRecognizer,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              color: _LoginScreenState._softWhite.withValues(alpha: 0.9),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Service',
                            recognizer: termsRecognizer,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              color: _LoginScreenState._softWhite.withValues(alpha: 0.9),
                            ),
                          ),
                          const TextSpan(text: '. Are you a '),
                          TextSpan(
                            text: 'professional?',
                            recognizer: psychiatristRecognizer,
                            style: GoogleFonts.inter(
                              fontSize: bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              color: _LoginScreenState._softWhite.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.11),
                    Colors.white.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthFormHeader extends StatelessWidget {
  const _AuthFormHeader({
    required this.title,
    required this.titleSize,
    required this.onBack,
  });

  final String title;
  final double titleSize;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF315A53);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(
            Icons.arrow_back,
            color: headerColor.withValues(alpha: 0.82),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Doto',
              fontSize: titleSize * 0.76,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              color: headerColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.bodySize,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final double bodySize;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    const fieldText = Color(0xFF3D6760);
    const fieldLabel = Color(0xFF6D8D87);
    const fieldFill = Color(0xFFEFF6F3);
    const fieldBorder = Color(0xFFC5D7D1);
    const fieldFocus = Color(0xFF8EB2AB);

    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: bodySize * 0.93,
          color: fieldText,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: bodySize * 0.88,
            color: fieldLabel,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          floatingLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF729891),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: fieldFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: fieldBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: fieldBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: fieldFocus, width: 1.3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE74C3C),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE74C3C),
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
          isDense: true,
        ),
      ),
    );
  }
}

class _AuthSubmitButton extends StatelessWidget {
  const _AuthSubmitButton({
    required this.text,
    required this.bodySize,
    required this.height,
    required this.onTap,
    this.isLoading = false,
  });

  final String text;
  final double bodySize;
  final double height;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const submitTextColor = Color(0xFFE8F4F1);

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4D9489), Color(0xFF3B7F75)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x243B7F75),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: bodySize * 1.05,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: submitTextColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StaggerReveal extends StatefulWidget {
  const _StaggerReveal({
    required this.child,
    required this.order,
  });

  final Widget child;
  final int order;

  @override
  State<_StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<_StaggerReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 70 + (widget.order * 65)), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        child: widget.child,
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onBack;

  const _SignUpForm({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.onBack,
  });

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerReveal(
          order: 0,
          child: _AuthFormHeader(
            title: 'Create Account',
            titleSize: widget.titleSize,
            onBack: widget.onBack,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _StaggerReveal(
                order: 1,
                child: _AuthInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  bodySize: widget.bodySize,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name required' : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 2,
                child: _AuthInputField(
                  controller: _emailController,
                  label: 'Email',
                  bodySize: widget.bodySize,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email required';
                    if (!value!.contains('@')) return 'Valid email required';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 3,
                child: _AuthInputField(
                  controller: _passwordController,
                  label: 'Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) => (value?.length ?? 0) < 6
                      ? 'Password must be 6+ characters'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 4,
                child: _AuthInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _StaggerReveal(
          order: 5,
          child: _AuthSubmitButton(
            text: 'Sign Up',
            bodySize: widget.bodySize,
            height: widget.buttonHeight,
            isLoading: _isLoading,
            onTap: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });

              final error = await _authService.registerGeneralUser(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (error == null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onBack;

  const _LoginForm({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.onBack,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerReveal(
          order: 0,
          child: _AuthFormHeader(
            title: 'Welcome Back',
            titleSize: widget.titleSize,
            onBack: widget.onBack,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _StaggerReveal(
                order: 1,
                child: _AuthInputField(
                  controller: _emailController,
                  label: 'Email or Username',
                  bodySize: widget.bodySize,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Email/username required'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 2,
                child: _AuthInputField(
                  controller: _passwordController,
                  label: 'Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Password required' : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _StaggerReveal(
          order: 3,
          child: _AuthSubmitButton(
            text: 'Login',
            bodySize: widget.bodySize,
            height: widget.buttonHeight,
            isLoading: _isLoading,
            onTap: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });

              final result = await _authService.loginUser(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (!result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.error ?? 'Login failed.'),
                  ),
                );
                return;
              }

              if (result.role == 'psychiatrist') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PsychiatristScreen()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ProfessionalForm extends StatefulWidget {
  final double titleSize;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onBack;

  const _ProfessionalForm({
    required this.titleSize,
    required this.bodySize,
    required this.buttonHeight,
    required this.onBack,
  });

  @override
  State<_ProfessionalForm> createState() => _ProfessionalFormState();
}

class _ProfessionalFormState extends State<_ProfessionalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _licenseController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _licenseController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StaggerReveal(
          order: 0,
          child: _AuthFormHeader(
            title: 'Professional Login',
            titleSize: widget.titleSize,
            onBack: widget.onBack,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _StaggerReveal(
                order: 1,
                child: _AuthInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  bodySize: widget.bodySize,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name required' : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 2,
                child: _AuthInputField(
                  controller: _licenseController,
                  label: 'License Number',
                  bodySize: widget.bodySize,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'License number required'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 3,
                child: _AuthInputField(
                  controller: _emailController,
                  label: 'Professional Email',
                  bodySize: widget.bodySize,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email required';
                    if (!value!.contains('@')) return 'Valid email required';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              _StaggerReveal(
                order: 4,
                child: _AuthInputField(
                  controller: _passwordController,
                  label: 'Password',
                  bodySize: widget.bodySize,
                  obscureText: true,
                  validator: (value) => (value?.length ?? 0) < 6
                      ? 'Password must be 6+ characters'
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _StaggerReveal(
          order: 5,
          child: _AuthSubmitButton(
            text: 'Verify & Login',
            bodySize: widget.bodySize,
            height: widget.buttonHeight,
            isLoading: _isLoading,
            onTap: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });

              final error = await _authService.registerProfessionalUser(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text,
                licenseNumber: _licenseController.text.trim(),
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (error == null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PsychiatristScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }
            },
          ),
        ),
      ],
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
    final imageHeight = MediaQuery.of(context).size.height * 0.5;

    return Stack(
      children: [
        Image.asset(
          'assets/imgs/intro-bg.png',
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF87AAA2).withValues(alpha: 0.22),
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
                      'assets/imgs/new-pet.png',
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
                    style: const TextStyle(
                      fontFamily: 'Doto',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: Color(0xFFFFFFFF),
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
                    color: const Color.fromARGB(255, 142, 192, 183).withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Already have an account?',
                  style: const TextStyle(
                    fontFamily: 'Doto',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B7A63),
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
