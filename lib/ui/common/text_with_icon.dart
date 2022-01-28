import 'package:flutter/material.dart';
import 'package:github_search/ui/common/my_text.dart';

class TextWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color textColor;

  const TextWithIcon({
    Key? key,
    required this.text,
    required this.icon,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        MyText(
          text,
          color: textColor,
        ),
      ],
    );
  }
}
