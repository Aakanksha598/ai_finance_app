import 'package:flutter/material.dart';

class CoinDrop extends StatefulWidget {
  final int index;
  final Duration startDelay; // stagger start
  final double pocketTopY; // local y where pocket mouth starts (clip target)

  const CoinDrop({
    super.key,
    required this.index,
    required this.startDelay,
    required this.pocketTopY,
  });

  @override
  State<CoinDrop> createState() => _CoinDropState();
}

class _CoinDropState extends State<CoinDrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _yAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _yAnim = Tween<double>(begin: -200.0, end: widget.pocketTopY)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_controller);

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 95),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 5),
    ]).animate(_controller);

    // Calculate the total delay for this coin's drop
    final totalDelay =
        widget.startDelay + Duration(milliseconds: widget.index * 100);

    // FIX: Call a separate async method for cleaner, delayed execution
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
    // Ensure the controller is disposed cleanly
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
            offset: Offset(0, _yAnim.value),
            child: const _CoinVisual(),
          ),
        );
      },
    );
  }
}

class _CoinVisual extends StatelessWidget {
  const _CoinVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF2A6),
            Color(0xFFF1C40F),
          ],
        ),
        border: Border.all(color: const Color(0xFFB7950B), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}


