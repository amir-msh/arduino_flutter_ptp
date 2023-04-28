import 'package:flutter/material.dart';

class SpinnerTransition extends AnimatedWidget {
  Animation<double> get animation => listenable as Animation<double>;
  final Alignment alignment;
  final FilterQuality? filterQuality;
  final Widget? child;

  const SpinnerTransition({
    Key? key,
    required Animation<double> animation,
    this.alignment = Alignment.center,
    this.filterQuality,
    this.child,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        filterQuality: filterQuality,
        scale: Tween<double>(begin: 0.66, end: 1).animate(animation),
        child: RotationTransition(
          filterQuality: filterQuality,
          turns: Tween<double>(begin: 0.6, end: 0).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
