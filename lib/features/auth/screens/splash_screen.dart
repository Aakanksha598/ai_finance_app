import 'package:ai_finance_app/features/auth/widgets/coin_drop.dart';
import 'package:ai_finance_app/features/auth/widgets/leather_pocket.dart';
import 'package:ai_finance_app/features/auth/widgets/pocket_card.dart';
import 'package:ai_finance_app/features/auth/widgets/rupee_logo_counter.dart';
import 'package:ai_finance_app/features/dashboard/screens/main_dashboard.dart';
import 'package:flutter/material.dart';

import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _timelineController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pocketIntro;
  late Animation<double> _logoPulse;
  late Animation<double> _titleOpacity;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Timeline duration is 4500ms (4.5s)
    _timelineController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pocketIntro = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.0, 0.111, curve: Curves.easeOut),
      ),
    );

    _logoPulse = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.622, 0.777, curve: Curves.easeInOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.822, 0.933, curve: Curves.easeIn),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Wait for initial fade to begin
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    _scaleController.forward();
    _timelineController.forward();

    // CORRECTED: Wait 4200ms here to ensure the 4500ms timeline animation finishes.
    // Total wait before navigation is 500ms + 4200ms = 4700ms.
    await Future.delayed(const Duration(milliseconds: 4200));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // TODO: Replace with actual onboarding check
    const hasCompletedOnboarding = false;

    if (!mounted) return; // Prevent navigation if widget is disposed

    if (hasCompletedOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainDashboard(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Royal purple vertical gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4B0082),
                  Color(0xFF6A0DAD),
                  Color(0xFF8E44AD),
                ],
              ),
            ),
          ),

          // Coins falling straight down into pocket
          const CoinDrop(
              index: 0,
              startDelay: Duration(milliseconds: 500),
              pocketTopY: -20),
          const CoinDrop(
              index: 1,
              startDelay: Duration(milliseconds: 600),
              pocketTopY: -20),
          const CoinDrop(
              index: 2,
              startDelay: Duration(milliseconds: 700),
              pocketTopY: -20),
          const CoinDrop(
              index: 3,
              startDelay: Duration(milliseconds: 800),
              pocketTopY: -20),
          const CoinDrop(
              index: 4,
              startDelay: Duration(milliseconds: 900),
              pocketTopY: -20),
          const CoinDrop(
              index: 5,
              startDelay: Duration(milliseconds: 1000),
              pocketTopY: -20),

          // Branding overlay (fade + scale as before)
          AnimatedBuilder(
            animation: _timelineController,
            builder: (context, _) {
              return LeatherPocket(
                fadeScaleProgress: _pocketIntro,
                childInside: RupeeLogoCounter(
                  startDelay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 700),
                  targetValue: 999,
                  pulse: _logoPulse,
                ),
              );
            },
          ),

          // Cards drop after coins
          const PocketCard(
              index: 10,
              startDelay: Duration(milliseconds: 1200),
              color: Color(0xFF3B82F6)),
          const PocketCard(
              index: 11,
              startDelay: Duration(milliseconds: 1350),
              color: Color(0xFF10B981)),
          const PocketCard(
              index: 12,
              startDelay: Duration(milliseconds: 1500),
              color: Color(0xFFF59E0B)),

          // Title fade-in at 3700-4200ms
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.28,
            child: AnimatedBuilder(
              animation: _timelineController,
              builder: (context, _) {
                return Opacity(
                  opacity: _titleOpacity.value,
                  child: const Text(
                    'Finance Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
