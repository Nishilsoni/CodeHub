import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authService = AuthService();
    if (authService.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using Lottie animation for a coding productivity animation
              Animate(
                child: Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_49rdyysj.json',
                  width: 200,
                  height: 200,
                ),
              ).fadeIn(duration: const Duration(milliseconds: 800))
               .scale(delay: const Duration(milliseconds: 200)),
              const SizedBox(height: 24),
              Text(
                'Code Hub',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 500))
                .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'Noise Low. Signal High. Vibes Perfect.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 700))
                .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
} 