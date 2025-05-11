import 'package:flutter/material.dart';

class BlinkingWarningView extends StatefulWidget {
  final String text;
  final Color color;
  final IconData icon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const BlinkingWarningView({
    super.key,
    required this.text,
    required this.color,
    this.icon = Icons.error,
    this.padding,
    this.textStyle,
  });

  @override
  State<BlinkingWarningView> createState() => _BlinkingWarningViewState();
}

class _BlinkingWarningViewState extends State<BlinkingWarningView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.only(top: 12),
      child: FadeTransition(
        opacity: _animation,
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color),
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: widget.textStyle ??
                  TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
