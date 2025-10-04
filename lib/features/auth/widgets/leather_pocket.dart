import 'package:flutter/material.dart';

class LeatherPocket extends StatefulWidget {
  final Animation<double> fadeScaleProgress; // 0..1, used for fade+scale
  final Widget?
      childInside; // content centered inside pocket (e.g., rupee logo + counter)

  const LeatherPocket({
    super.key,
    required this.fadeScaleProgress,
    this.childInside,
  });

  @override
  State<LeatherPocket> createState() => _LeatherPocketState();
}

class _LeatherPocketState extends State<LeatherPocket> {
  @override
  Widget build(BuildContext context) {
    final opacity = widget.fadeScaleProgress.clamp(0.0, 1.0);
    final scale = 0.9 + 0.1 * opacity; // 90% -> 100%

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: _PocketBody(childInside: widget.childInside),
      ),
    );
  }
}

class _PocketBody extends StatelessWidget {
  final Widget? childInside;

  const _PocketBody({required this.childInside});

  @override
  Widget build(BuildContext context) {
    // A simple stylized leather pocket using gradients and subtle borders
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 160,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B2A24), // dark leather brown
                Color(0xFF5A3E33),
              ],
            ),
            border: Border.all(color: Colors.black12, width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38, blurRadius: 18, offset: Offset(0, 10)),
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
        ),
        // Top stitching line to hint leather
        Positioned(
          top: 14,
          left: 16,
          right: 16,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Inner bevel
        Container(
          width: 160,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.black.withOpacity(0.10),
              ],
            ),
          ),
        ),
        if (childInside != null) childInside!,
      ],
    );
  }
}


