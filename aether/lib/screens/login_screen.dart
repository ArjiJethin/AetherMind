import 'dart:ui' show ImageFilter, clampDouble;

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
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenTransition = CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeOutCubic,
    );

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
                height: screenHeight * 0.5,
                child: const _FullScreenBackgroundImage(),
              ),
            ),

            // Ambient decorations
            const Positioned.fill(child: _AmbientBackdrop()),

            // Very soft readability transition around the split.
            const Positioned.fill(child: _MidScreenReadabilityGradient()),

            if (_currentScreen == 'main')
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final petSize = clampDouble(width * 1.3, 400, 580);
                    final titleSize = clampDouble(width * 0.075, 29, 37);
                    final bodySize = clampDouble(width * 0.033, 13, 14.5);
                    final buttonHeight = clampDouble(
                      constraints.maxHeight * 0.075,
                      56,
                      60,
                    );

                    final bgImageHeight = screenHeight * 0.5;
                    final topSectionHeight = bgImageHeight - mediaQuery.padding.top;

                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: topSectionHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: petSize * 0.5,
                                  child: _PetOverlay(
                                    petSize: petSize,
                                    floatOffset: _floatOffset,
                                    glowStrength: _glowStrength,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: clampDouble(width * 0.1, 22, 40),
                                  ),
                                  child: Text(
                                    'Aether grows with you, one step at a time.',
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
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: bgImageHeight,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            child: _BottomAttachedMainPanel(
                              buttonHeight: buttonHeight,
                              bodySize: bodySize,
                              onStartJourney: _handleStartJourney,
                              onExistingAccount: _handleExistingAccount,
                              privacyRecognizer: _privacyRecognizer,
                              termsRecognizer: _termsRecognizer,
                              psychiatristRecognizer: _psychiatristRecognizer,
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
              Positioned(
                top: screenHeight * 0.5,
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: screenTransition,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(screenTransition),
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
                ),
              ),
          ],
        ),
      ),
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

          return Stack(
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
    const softWhite = Color(0xFFF7FFFB);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(
            Icons.arrow_back,
            color: softWhite.withValues(alpha: 0.85),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: titleSize * 0.76,
              fontWeight: FontWeight.w600,
              color: softWhite,
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
    const softWhite = Color(0xFFF7FFFB);

    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.inter(
          fontSize: bodySize * 0.93,
          color: softWhite,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: bodySize * 0.88,
            color: softWhite.withValues(alpha: 0.62),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: softWhite.withValues(alpha: 0.035),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: softWhite.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: softWhite.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: softWhite.withValues(alpha: 0.45),
              width: 1.2,
            ),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                colors: [Color(0xFF3A8B81), Color(0xFF2A6560)],
              ),
              borderRadius: BorderRadius.circular(14),
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
                    style: GoogleFonts.inter(
                      fontSize: bodySize * 1.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

              final success = await _authService.registerGeneralUser(
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

              if (success) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create account.')),
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

              final role = await _authService.loginUser(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );

              if (!mounted) {
                return;
              }

              setState(() {
                _isLoading = false;
              });

              if (role == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login failed.')),
                );
                return;
              }

              if (role == 'psychiatrist') {
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

              final success = await _authService.registerProfessionalUser(
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

              if (success) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PsychiatristScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Professional login failed.')),
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
