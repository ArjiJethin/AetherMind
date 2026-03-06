import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEEF2FF),
              Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Optimized background blur circles - using const where possible
            _buildBackgroundBlur(
              top: -120,
              right: -80,
              size: 380,
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.15),
                const Color(0xFF60A5FA).withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            _buildBackgroundBlur(
              bottom: -100,
              left: -120,
              size: 420,
              colors: [
                const Color(0xFF2563EB).withOpacity(0.18),
                const Color(0xFF3B82F6).withOpacity(0.12),
                Colors.transparent,
              ],
            ),
            _buildBackgroundBlur(
              top: 220,
              left: 40,
              size: 280,
              colors: [
                const Color(0xFF60A5FA).withOpacity(0.15),
                const Color(0xFF93C5FD).withOpacity(0.08),
                Colors.transparent,
              ],
            ),
            _buildBackgroundBlur(
              bottom: 180,
              right: 50,
              size: 320,
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.15),
                const Color(0xFF60A5FA).withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24.0 : 32.0,
                    vertical: 40.0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLogoSection(),
                          const SizedBox(height: 48),
                          _buildLoginCard(context),
                          const SizedBox(height: 24),
                          _buildSocialLoginSection(),
                          const SizedBox(height: 32),
                          _buildSignUpSection(),
                        ],
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

  // Optimized background blur widget
  Widget _buildBackgroundBlur({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required List<Color> colors,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Wolfie mascot - clean display with subtle shadow
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Hero(
                tag: 'wolfie_logo',
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 8,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/imgs/wolfie.png',
                      fit: BoxFit.cover,
                      cacheWidth: 360,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 36),
        
        // App name with subtle gradient - Using Poppins for title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF2563EB),
            ],
          ).createShader(bounds),
          child: Text(
            'Aether',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Text(
          'Welcome back! Sign in to continue',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: GoogleFonts.inter(
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your credentials to access your account',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                
                // Decorative top accent
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF60A5FA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Decorative top accent
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF60A5FA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 28),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3B82F6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                // Sign in button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _handleSignIn,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              label: 'Google',
              iconData: FontAwesomeIcons.google,
              iconColor: const Color(0xFFDB4437),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              label: 'Apple',
              iconData: FontAwesomeIcons.apple,
              iconColor: Colors.black,
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              label: 'Facebook',
              iconData: FontAwesomeIcons.facebookF,
              iconColor: const Color(0xFF1877F2),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Text(
                "Don't have an account?",
                style: GoogleFonts.inter(
                  color: const Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 18,
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
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
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData iconData,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: FaIcon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }
}
