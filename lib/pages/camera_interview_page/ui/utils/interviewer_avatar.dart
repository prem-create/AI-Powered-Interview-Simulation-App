import 'package:flutter/material.dart';

/// A pulsing gradient orb representing the AI interviewer's presence.
/// Replaces the old camera-preview placeholder — no image asset required.
class InterviewerAvatar extends StatefulWidget {
  const InterviewerAvatar({super.key, required this.size});
  final double size;

  @override
  State<InterviewerAvatar> createState() => _InterviewerAvatarState();
}

class _InterviewerAvatarState extends State<InterviewerAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.9 + (_controller.value * 0.1); // 0.9 -> 1.0 scale
        final glow = 0.15 + (_controller.value * 0.15); // 0.15 -> 0.30 opacity
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5B6EF5), Color(0xFF3AA0FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3AA0FF).withAlpha(glow.toInt()),
                blurRadius: 30,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: pulse,
              child: Icon(
                Icons.graphic_eq_rounded,
                color: Colors.white,
                size: widget.size * 0.4,
              ),
            ),
          ),
        );
      },
    );
  }
}