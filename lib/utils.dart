import 'package:flutter/material.dart';


const emptyWidget = SizedBox(width: 0, height: 0);

void printLong(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Widget navigate(Function function, BuildContext context, Widget newPage) {
  // navigate in microtask to prevent Flutter from throwing error
  Future.microtask(() => function(context, MaterialPageRoute(builder: (context) => newPage)));
  return emptyWidget;
}

String dateToString(DateTime dateTime) => dateTime.toString().substring(0, 19);


Future<T> showLoading <T> (BuildContext context, Future<T> future, {String? text}) async {
  var children = <Widget>[const CircularProgressIndicator()];
  if (text != null) {
    children.add(const SizedBox(height: 16));
    children.add(Text(
      text,
    ));
  }
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(          
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      );
    }
  );
  T rv = await future;
  if (context.mounted) {
    Navigator.pop(context);
  }
  return rv;
}