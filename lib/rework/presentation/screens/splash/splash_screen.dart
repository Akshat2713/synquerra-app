import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../app/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  bool _animationDone = false;
  bool _authCheckDone = false;
  String? _navigateTo;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Pop scale: starts small, overshoots, settles
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();

      // Trigger auth check
      context.read<AuthBloc>().add(AuthCheckStatusRequested());
    });

    // Mark animation done after minimum splash duration
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _animationDone = true);
        _tryNavigate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tryNavigate() {
    if (_animationDone && _authCheckDone && _navigateTo != null) {
      Navigator.pushReplacementNamed(context, _navigateTo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          debugPrint('[SplashScreen] Auth check done → authenticated');
          _authCheckDone = true;
          _navigateTo = AppRoutes.home;
          _tryNavigate();
        } else if (state is AuthUnauthenticated) {
          debugPrint('[SplashScreen] Auth check done → unauthenticated');
          _authCheckDone = true;
          _navigateTo = AppRoutes.login;
          _tryNavigate();
        }
      },
      child: Scaffold(
        backgroundColor: colors.primary,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(scale: _scaleAnimation, child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo container ─────────────────────
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // ── Company name ───────────────────────
                Text(
                  'Synquerra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track. Monitor. Protect.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
