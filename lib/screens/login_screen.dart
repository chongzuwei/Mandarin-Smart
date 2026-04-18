import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth/register_screen.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    // Slide-up animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Floating decorative elements
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _floatingAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _floatingController,
    );
    _floatingController.repeat();

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      // Show success (replace with actual navigation)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome to MandarinSmart! 🎉',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Stack(
          children: [
            // ── Floating Decorative Orbs ─────────────────────────
            _buildFloatingOrbs(size),

            // ── Main Content ─────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 12),
                        _buildTitle(),
                        const SizedBox(height: 8),
                        _buildSubtitle(),
                        const SizedBox(height: 32),
                        _buildLoginForm(),
                        const SizedBox(height: 16),
                        _buildRememberAndForgot(),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 20),
                        _buildSocialLogin(),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                      ],
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

  // ── Floating Orbs ───────────────────────────────────────────────
  Widget _buildFloatingOrbs(Size size) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final v = _floatingAnimation.value;
        return Stack(
          children: [
            // Top-right orb
            Positioned(
              top: size.height * 0.05 + math.sin(v) * 20,
              right: -40 + math.cos(v) * 15,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryRed.withOpacity(0.25),
                      AppTheme.primaryRed.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-left orb
            Positioned(
              bottom: size.height * 0.15 + math.cos(v) * 25,
              left: -60 + math.sin(v) * 10,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentGold.withOpacity(0.15),
                      AppTheme.accentGold.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Mid-center small orb
            Positioned(
              top: size.height * 0.4 + math.sin(v + 1.5) * 15,
              right: size.width * 0.1 + math.cos(v + 1.5) * 10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryRedLight.withOpacity(0.12),
                      AppTheme.primaryRedLight.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Logo ────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.primaryShadow,
        ),
        child: const Center(
          child: Text(
            '中',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ── Title ───────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Text(
      'MandarinSmart',
      style: AppTheme.headingLarge.copyWith(
        color: AppTheme.textPrimary,
        fontSize: 30,
      ),
    );
  }

  // ── Subtitle ────────────────────────────────────────────────────
  Widget _buildSubtitle() {
    return Text(
      'UTM Mandarin Club',
      style: AppTheme.bodyLarge.copyWith(
        color: AppTheme.textSecondary,
        letterSpacing: 2,
      ),
    );
  }

  // ── Login Form ──────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          _buildTextField(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password field
          _buildTextField(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        gradient: AppTheme.cardGradient,
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
        cursorColor: AppTheme.primaryRed,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          errorStyle: AppTheme.bodySmall.copyWith(
            color: AppTheme.primaryRedLight,
          ),
        ),
      ),
    );
  }

  // ── Remember Me & Forgot Password ──────────────────────────────
  Widget _buildRememberAndForgot() {
    return Row(
      children: [
        // Remember me
        GestureDetector(
          onTap: () {
            setState(() => _rememberMe = !_rememberMe);
            HapticFeedback.selectionClick();
          },
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient:
                      _rememberMe ? AppTheme.primaryGradient : null,
                  border: _rememberMe
                      ? null
                      : Border.all(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          width: 1.5,
                        ),
                ),
                child: _rememberMe
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Forgot password
        GestureDetector(
          onTap: () {
            // Navigate to forgot password
          },
          child: Text(
            'Forgot password?',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryRedLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Login Button ────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.primaryShadow,
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: AppTheme.buttonText
                          .copyWith(color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Divider ─────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.dividerColor,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.dividerColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Social Login ────────────────────────────────────────────────
  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Google',
          iconSize: 28,
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: Icons.apple_rounded,
          label: 'Apple',
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    double iconSize = 24,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Ink(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              gradient: AppTheme.cardGradient,
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.textPrimary, size: iconSize),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTheme.labelMedium
                      .copyWith(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign Up Link ────────────────────────────────────────────────
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style:
              AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.primaryRedLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
