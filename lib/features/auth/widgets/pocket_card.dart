import 'dart:math' as math;

import 'package:flutter/material.dart';

class PocketCard extends StatefulWidget {
  final int index;
  final Duration startDelay;
  final Color color;

  const PocketCard({
    super.key,
    required this.index,
    required this.startDelay,
    required this.color,
  });

  @override
  State<PocketCard> createState() => _PocketCardState();
}

class _PocketCardState extends State<PocketCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _yAnim;
  late final Animation<double> _xAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _rotateAnim;

  late final double _initialRotationRad;
  late final double _initialOffsetX;

  @override
  void initState() {
    super.initState();

    // Seed randomness by index so multiple instances are deterministic
    final rand = math.Random(widget.index);
    _initialRotationRad = ((rand.nextDouble() - 0.5) * 20) * (math.pi / 180.0);
    _initialOffsetX = (rand.nextDouble() - 0.5) * 25;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Map JS keyframes:
    // y: [-200, -80, -40]
    _yAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -200.0, end: -80.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -80.0, end: -40.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    // x: [initialX, initialX*0.7, initialX*0.3]
    _xAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween:
            Tween<double>(begin: _initialOffsetX, end: _initialOffsetX * 0.7),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
            begin: _initialOffsetX * 0.7, end: _initialOffsetX * 0.3),
        weight: 30,
      ),
    ]).animate(_controller);

    // opacity: [1, 1, 0]
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    // rotate: [rotation, rotation*0.5, 0]
    _rotateAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
            begin: _initialRotationRad, end: _initialRotationRad * 0.5),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _initialRotationRad * 0.5, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    final totalDelay =
        widget.startDelay + Duration(milliseconds: widget.index * 150);
    _startDrop(totalDelay);
  }

  void _startDrop(Duration delay) async {
    await Future.delayed(delay);
    if (mounted) {
      _controller.forward();
    }
  }

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
        return Opacity(
          opacity: _opacityAnim.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(_xAnim.value, _yAnim.value),
            child: Transform.rotate(
              angle: _rotateAnim.value,
              child: SizedBox(
                width: 32,
                height: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(3),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        width: 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.amber[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 2,
                            width: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: 2,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


