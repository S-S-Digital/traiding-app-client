import 'dart:async';

import 'package:aspiro_trade/features/splash/cubit/splash_cubit.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Preloader switch ──────────────────────────────────────────────
  // The старый видео-прелоадер (assets/video/preloader.mp4) ВРЕМЕННО скрыт,
  // но НЕ удалён — его код сохранён ниже за этим флагом, чтобы вернуть позже.
  // Сейчас показываем брендовый лого-сплэш (логотип + название + анимация).
  static const bool _useVideoPreloader = false;

  // Минимальное время показа лого-сплэша, чтобы анимация успела отыграть.
  static const Duration _minDisplay = Duration(milliseconds: 2200);

  // ── Video preloader state (kept for the disabled path) ────────────
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoFinished = false;

  // ── Logo splash state ─────────────────────────────────────────────
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  bool _minTimeElapsed = false;

  // ── Navigation state ──────────────────────────────────────────────
  bool _hasNavigated = false;
  SplashState? _pendingState;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);

    if (_useVideoPreloader) {
      _initVideo();
    } else {
      // Лого-сплэш: ведём навигацию по минимальному времени показа.
      Timer(_minDisplay, () {
        if (!mounted) return;
        setState(() => _minTimeElapsed = true);
        _checkAndNavigate();
      });
    }

    // Hard failsafe — the splash must never hang. Even if the cubit's 12s
    // refresh timeout is somehow bypassed, this forces navigation at 15s.
    Timer(const Duration(seconds: 15), _failsafeNavigate);

    // Start background auth check immediately
    context.read<SplashCubit>().initializeApp();
  }

  // ── Video preloader (HIDDEN — kept intact, re-enable via flag) ─────
  Future<void> _initVideo() async {
    final controller =
        VideoPlayerController.asset('assets/video/preloader.mp4');
    _videoController = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _videoInitialized = true;
      });

      // Play the video silently (muted preloader)
      await controller.setVolume(0.0);
      await controller.play();

      controller.addListener(() {
        if (!mounted) return;
        final pos = controller.value.position;
        final dur = controller.value.duration;
        if (pos >= dur && !_videoFinished) {
          setState(() {
            _videoFinished = true;
          });
          _checkAndNavigate();
        }
      });
    } catch (_) {
      // In case video initialization fails, fallback gracefully.
      setState(() {
        _videoFinished = true;
      });
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    final state = _pendingState;
    final timingReady = _useVideoPreloader ? _videoFinished : _minTimeElapsed;
    if (timingReady && state is SplashLoaded && mounted && !_hasNavigated) {
      _go(state.isAuthenticated);
    }
  }

  // Hard failsafe: if SplashLoaded never arrives (e.g. a stalled refresh/native
  // channel slips past the cubit's own timeout), force navigation anyway so the
  // app can NEVER hang on the loading screen. A stall only happens in the
  // refresh branch, which runs solely when a refresh token exists — so default
  // to the authenticated (Home) route here.
  void _failsafeNavigate() {
    if (_hasNavigated || !mounted) return;
    _go(_pendingState is SplashLoaded
        ? (_pendingState as SplashLoaded).isAuthenticated
        : true);
  }

  void _go(bool isAuthenticated) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    setState(() {
      _opacity = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final router = AutoRouter.of(context);
      router.pushAndPopUntil(
        isAuthenticated ? const HomeRoute() : const LoginRoute(),
        predicate: (_) => false,
      );
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            _pendingState = state;
            _checkAndNavigate();
          }
        },
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: _useVideoPreloader ? _buildVideo() : _buildLogoSplash(),
        ),
      ),
    );
  }

  // ── HIDDEN video body (kept) ──────────────────────────────────────
  Widget _buildVideo() {
    final controller = _videoController;
    return Center(
      child: _videoInitialized && controller != null
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ── Branded logo splash (current) ─────────────────────────────────
  Widget _buildLogoSplash() {
    final intro = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    final textIntro = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    final taglineIntro = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo with soft pulsing brand glow.
          AnimatedBuilder(
            animation: Listenable.merge([intro, _pulseController]),
            builder: (context, child) {
              final glow = 0.18 + 0.14 * _pulseController.value;
              return Opacity(
                opacity: intro.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + 0.15 * intro.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: glow),
                          blurRadius: 48,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset(
              'assets/logo/logo_transparent.png',
              width: 116,
              height: 116,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 28),

          // Wordmark — "Aspiro" (brand) + "Trade" (white), fade + slide up.
          AnimatedBuilder(
            animation: textIntro,
            builder: (context, _) {
              return Opacity(
                opacity: textIntro.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - textIntro.value)),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Aspiro ',
                          style: TextStyle(color: AppColors.brand),
                        ),
                        TextSpan(
                          text: 'Trade',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Tagline.
          AnimatedBuilder(
            animation: taglineIntro,
            builder: (context, _) {
              return Opacity(
                opacity: taglineIntro.value.clamp(0.0, 1.0),
                child: const Text(
                  'AI Trading Signals',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 44),

          // Subtle brand activity indicator.
          AnimatedBuilder(
            animation: taglineIntro,
            builder: (context, _) {
              return Opacity(
                opacity: taglineIntro.value.clamp(0.0, 1.0),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.brand),
                    backgroundColor: AppColors.brand.withValues(alpha: 0.15),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
