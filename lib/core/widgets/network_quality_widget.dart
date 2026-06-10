import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NetworkQualityWidget extends StatelessWidget {
  final int quality;
  const NetworkQualityWidget({super.key, required this.quality});

  Color get _color {
    if (quality <= 1) return AppTheme.successColor;
    if (quality <= 3) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String get _label {
    switch (quality) {
      case 0:
      case 1:
        return 'Excellent';
      case 2:
        return 'Good';
      case 3:
        return 'Fair';
      case 4:
        return 'Poor';
      case 5:
        return 'Bad';
      default:
        return 'No Signal';
    }
  }

  int get _bars => switch (quality) {
        0 => 4,
        1 => 4,
        2 => 3,
        3 => 2,
        4 => 1,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SignalIcon(bars: _bars, color: _color),
        const SizedBox(width: 4),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SignalIcon extends StatelessWidget {
  final int bars;
  final Color color;
  const _SignalIcon({required this.bars, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final filled = i < bars;
        return Container(
          width: 3,
          height: 5.0 + i * 3,
          margin: const EdgeInsets.only(right: 1.5),
          decoration: BoxDecoration(
            color: filled ? color : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
