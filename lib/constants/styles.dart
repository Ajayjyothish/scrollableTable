import 'package:flutter/material.dart';

const purpleBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
  gradient: LinearGradient(
    colors: [Colors.purple, Colors.deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);

const roundedBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(10)),
);
