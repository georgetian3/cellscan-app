// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:flutter_cell_info/CellResponse.dart';
import 'package:flutter_cell_info/SIMInfoResponse.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:flutter_cell_info/models/common/cell_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:developer';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   CellsResponse? _cellsResponse;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  String? currentDBM;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    CellsResponse? cellsResponse;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String? platformVersion = await CellInfo.getCellInfo;
      
      final body = json.decode(platformVersion!);
      cellsResponse = CellsResponse.fromJson(body);
      
      print('neighobring cell list');
      if (cellsResponse.neighboringCellList != null) {
        for (final x in cellsResponse.neighboringCellList!) {
          print(x.toJson());
        }
      }
      print('primary cell list');
      if (cellsResponse.primaryCellList != null) {
        for (final x in cellsResponse.primaryCellList!) {
          print(x.toJson());
        }
      }
      print('cell data list');
      if (cellsResponse.cellDataList != null) {
        for (final x in cellsResponse.cellDataList!) {
          print(x.toJson());
        }
      }

      CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
      if (currentCellInFirstChip.type == "LTE") {
        currentDBM =
            "LTE dbm = ${currentCellInFirstChip.lte?.signalLTE?.dbm}" ;
      } else if (currentCellInFirstChip.type == "NR") {
        currentDBM =
            "NR dbm = ${currentCellInFirstChip.nr?.signalNR?.dbm}" ;
      } else if (currentCellInFirstChip.type == "WCDMA") {
        currentDBM = "WCDMA dbm = ${currentCellInFirstChip.wcdma?.signalWCDMA?.dbm}" ;

        print('currentDBM = ' + currentDBM!);
      }

      String? simInfo = await CellInfo.getSIMInfo;
      final simJson = json.decode(simInfo!);
      print(
          "desply name ${SIMInfoResponse.fromJson(simJson).simInfoList![0].displayName}");
    } on PlatformException {
      _cellsResponse = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _cellsResponse = cellsResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _cellsResponse != null
            ? Center(
                child: Text(
                    'mahmoud = ${currentDBM}\n primary = ${_cellsResponse?.primaryCellList?.length.toString()} \n neighbor = ${_cellsResponse?.neighboringCellList?.length}'),
              )
            : null,
      ),
    );
  }

  Timer? timer;

  void startTimer() {
    const oneSec = const Duration(seconds: 3);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        initPlatformState();
      },
    );
  }

}