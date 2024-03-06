
import 'package:flutter/material.dart';

const emptyWidget = SizedBox(width: 0, height: 0);

void printLong(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Widget navigate(Function function, BuildContext context, Widget newPage) {
  Future.microtask(() => function(context, MaterialPageRoute(builder: (context) => newPage)));
  return emptyWidget;
}