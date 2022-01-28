import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const MyText(
    this.text, {
    Key? key,
    this.color = Colors.black,
    this.size = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
    );
  }
}
