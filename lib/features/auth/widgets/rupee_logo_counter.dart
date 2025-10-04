import 'package:flutter/material.dart';

class RupeeLogoCounter extends StatefulWidget {
  final Duration startDelay;
  final Duration duration; // total counting duration while coins drop
  final int targetValue;
  final Animation<double>? pulse; // optional external pulse animation 0..1

  const RupeeLogoCounter({
    super.key,
    required this.startDelay,
    required this.duration,
    required this.targetValue,
    this.pulse,
  });

  @override
  State<RupeeLogoCounter> createState() => _RupeeLogoCounterState();
}

class _RupeeLogoCounterState extends State<RupeeLogoCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _countAnim = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(widget.startDelay).then((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safely retrieve the pulse value, defaulting to 0.0 if null
    final glow = widget.pulse?.value ?? 0.0;

    final scale = 1.0 + 0.05 * glow; // slight pulse 1.0->1.05
    final glowOpacity = 0.3 * glow;

    // Listens to both the internal counting animation and the external pulse animation
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_controller, if (widget.pulse != null) widget.pulse!]),
      builder: (context, _) {
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // soft glow
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(glowOpacity),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.25 * glow),
                        blurRadius: 16,
                        spreadRadius: 4),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Using a dark color for contrast against the white background
                      const Icon(Icons.currency_rupee,
                          size: 24, color: Colors.black),
                      Text(
                        _countAnim.value.toString(),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


