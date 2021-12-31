import 'package:flutter/material.dart';

class ExtendedIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  const ExtendedIconButton({
    Key? key,
    required this.icon,
    this.color = const Color(0xFF000000),
    this.size = 24.0,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size + 16,
        height: size + 16,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: size,
            color: color,
          ),
        ));
  }
}
