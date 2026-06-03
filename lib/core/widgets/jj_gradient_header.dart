import 'package:flutter/material.dart';

import '../../app/theme.dart';

class JJGradientHeader extends StatelessWidget {
  final double height;
  final Widget? child;
  final EdgeInsets padding;

  const JJGradientHeader({
    super.key,
    this.height = 240,
    this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: JJColors.gradientPurple,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
