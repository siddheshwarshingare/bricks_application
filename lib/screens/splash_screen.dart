import 'package:bricks_application/login_screen.dart';
import 'package:bricks_application/screens/factory/factory/factory_list_screen.dart';
import 'package:bricks_application/services/auth_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color primaryColor = Color(0xFFC4471C);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      try {
        debugPrint("SPLASH: Checking login session...");

        final isLoggedIn = await AuthService.isLoggedIn();

        debugPrint("SPLASH: isLoggedIn = $isLoggedIn");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isLoggedIn ? const FactoryListScreen() : const LoginScreen(),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint("SPLASH ERROR: $e");
        debugPrint("$stackTrace");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final isLoggedIn = await AuthService.isLoggedIn();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isLoggedIn ? const FactoryListScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD85B2D), Color(0xFFC4471C), Color(0xFF963012)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/gromore_logo.gif',
                  width: 300,
                  height: 270,
                  fit: BoxFit.contain,
                ),
                // child: Container(
                //   height: 130,
                //   width: 130,
                //   padding: const EdgeInsets.all(15),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(30),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withValues(alpha: 0.2),
                //         blurRadius: 25,
                //         offset: const Offset(0, 12),
                //       ),
                //     ],
                //   ),
                //   child: Image.asset(
                //     'assets/bricks1.webp',
                //     fit: BoxFit.contain,
                //   ),
                // ),
              ),

              const SizedBox(height: 30),

              const Text(
                'BRICK FACTORY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Smart Factory Management',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(),

              const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
