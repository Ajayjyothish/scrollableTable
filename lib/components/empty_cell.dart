import 'package:flutter/material.dart';

class EmptyCell extends StatelessWidget {
  final double height;
  final double width;

  const EmptyCell({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: height,
      width: width,
      margin: const EdgeInsets.all(4.0),
      child: const Text("", style: TextStyle(fontSize: 15)),
    );
  }
}
