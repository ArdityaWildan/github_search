import 'package:flutter/material.dart';

class SearchableItem extends StatelessWidget {
  final Function() action;
  final Widget child;

  const SearchableItem({
    Key? key,
    required this.action,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}
