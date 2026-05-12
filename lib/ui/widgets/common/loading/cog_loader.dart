import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class CogLoader extends StatelessWidget {
  final double size;
  final Color color;

  const CogLoader({
    super.key,
    this.size = 72,
    this.color = AppColors.textHint,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitChasingDots(
      color: color,
      size: size,
    );
  }
}
