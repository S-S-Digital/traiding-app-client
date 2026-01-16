
import 'package:flutter/material.dart';

class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const BlinkingDot({
    super.key,
    this.color = Colors.green,
    this.size = 15,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
