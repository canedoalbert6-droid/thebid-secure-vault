import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double tiltSensitivity;

  const TiltCard({super.key, required this.child, this.tiltSensitivity = 0.05});

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double xOffset = 0;
  double yOffset = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          final localPosition = renderBox.globalToLocal(details.position);
          
          final dx = localPosition.dx - size.width / 2;
          final dy = localPosition.dy - size.height / 2;

          setState(() {
            yOffset = -dx * widget.tiltSensitivity;
            xOffset = dy * widget.tiltSensitivity;
          });
        }
      },
      onExit: (_) {
        setState(() {
          xOffset = 0;
          yOffset = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(xOffset)
          ..rotateY(yOffset),
        child: widget.child,
      ),
    );
  }
}
