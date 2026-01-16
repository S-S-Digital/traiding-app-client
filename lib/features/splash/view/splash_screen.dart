import 'dart:async';

import 'package:aspiro_trade/features/splash/cubit/splash_cubit.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dropAnimation;
  late final Animation<double> _opacityAnimation;

  String _displayedText = '';
  final String _fullText = 'Добро пожаловать в Aspiro Trade!';
  int _currentIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();

    // Инициализация анимации падения
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _dropAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Запуск эффекта печатающегося текста
    _startTyping();

    // Инициализация приложения через кубит после задержки
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.read<SplashCubit>().initializeApp();
    });
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white);

    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded && mounted) {
            final router = AutoRouter.of(context);
            if (state.isAuthenticated) {
              router.pushAndPopUntil(
                const HomeRoute(),
                predicate: (_) => false,
              );
            } else {
              router.pushAndPopUntil(
                const LoginRoute(),
                predicate: (_) => false,
              );
            }
          }
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 100 * (1 - _dropAnimation.value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _displayedText,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
