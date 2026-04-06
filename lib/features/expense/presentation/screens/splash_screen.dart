import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate after animation completes
    Future.delayed(const Duration(milliseconds: 6000), () {
      if (mounted) _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final navigator = Navigator.of(context);
    final authService = getIt<AuthService>();
    final biometricService = getIt<BiometricService>();

    // Try silent sign-in first
    final silentSuccess = await authService.trySilentSignIn();

    if (!mounted) return;

    if (silentSuccess) {
      // Already signed in — check biometric lock
      final biometricEnabled = await biometricService.isBiometricEnabled();
      if (biometricEnabled) {
        navigator.pushReplacementNamed('/lock');
      } else {
        navigator.pushReplacementNamed('/home');
      }
    } else {
      // Not signed in — show sign-in screen
      navigator.pushReplacementNamed('/sign-in');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Animated gradient colors based on logo color #88304e
    final List<Color> gradientStart = isDark
        ? [const Color(0xFF88304E), const Color(0xFF2D142C)]
        : [const Color(0xFF88304E), const Color(0xFFF8E1F4)];
    final List<Color> gradientEnd = isDark
        ? [const Color(0xFF2D142C), const Color(0xFF88304E)]
        : [const Color(0xFFF8E1F4), const Color(0xFF88304E)];

    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        // Interpolate between two gradients
        List<Color> colors = List.generate(2, (i) {
          return Color.lerp(
            gradientStart[i],
            gradientEnd[i],
            _gradientAnimation.value,
          )!;
        });
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient( 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          'assets/logo/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Expense Tracker',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF88304E),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white : const Color(0xFF88304E),
                        ),
                      ),
                    ],
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
