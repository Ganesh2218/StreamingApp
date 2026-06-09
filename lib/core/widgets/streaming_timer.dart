import 'package:flutter/material.dart';

/// Monospace streaming timer display for host live screen
class StreamingTimer extends StatelessWidget {
  final String elapsed;
  const StreamingTimer({super.key, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
      ),
      child: Text(
        elapsed,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
          letterSpacing: 1,
        ),
      ),
    );
  }
}
