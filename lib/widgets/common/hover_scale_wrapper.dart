import 'package:flutter/material.dart';

/// A lightweight hover/focus scale wrapper for non-card interactive items.
/// Use this on list tiles, buttons, nav items — anything that is NOT a C4Card.
class HoverScaleWrapper extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverScaleWrapper({
    super.key,
    required this.child,
    this.hoverScale = 1.03,
    this.duration = const Duration(milliseconds: 180),
    this.onTap,
  });

  @override
  State<HoverScaleWrapper> createState() => _HoverScaleWrapperState();
}

class _HoverScaleWrapperState extends State<HoverScaleWrapper> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _active = true),
      onExit: (_) => setState(() => _active = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _active ? widget.hoverScale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
