
import 'dart:convert';

import 'package:cellscan/measurement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cell_info/CellResponse.dart';
import 'dart:async';

import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:flutter_cell_info/models/common/cell_type.dart';

import 'package:geolocator/geolocator.dart';


Future<Position> getPosition() async {
  print('getting position');
  return await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 5));
}

Future<String> getCellInfo() async {
  print('logging');
  return 'scan cell info';

  // if (!await Geolocator.isLocationServiceEnabled()) {
  //   print('Location service disabled');
  //   return;
  // }

  // Measurement measurement = Measurement();

  


  // try {
  //   String? platformVersion = await CellInfo.getCellInfo;
  //   final body = json.decode(platformVersion!);
  //   final cellsResponse = CellsResponse.fromJson(body);

  //   CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
  //   // if (currentCellInFirstChip.type == "LTE") {
  //   //   currentDBM =
  //   //       "LTE dbm = ${currentCellInFirstChip.lte?.signalLTE?.dbm}" ;
  //   // } else if (currentCellInFirstChip.type == "NR") {
  //   //   currentDBM =
  //   //       "NR dbm = ${currentCellInFirstChip.nr?.signalNR?.dbm}" ;
  //   // } else if (currentCellInFirstChip.type == "WCDMA") {
  //   //   currentDBM = "WCDMA dbm = ${currentCellInFirstChip.wcdma?.signalWCDMA?.dbm}" ;

  //   //   print('currentDBM = ' + currentDBM!);
  //   // }

  //   // String? simInfo = await CellInfo.getSIMInfo;
  //   // final simJson = json.decode(simInfo!);
  //   // print(
  //   //     "desply name ${SIMInfoResponse.fromJson(simJson).simInfoList![0].displayName}");
  // } on PlatformException catch (e) {
  //   print('scan exception: $e');
  // }
}




void scan() {
  Future.wait([
    getPosition(),
    getCellInfo()
  ]).then((value) => {
    
    
    print(value)
    
  });

}



class ScanPage extends StatelessWidget {

  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CellScan - Scan'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: scan, child: Text('Scan')),
            Text('Previous scan: '),
            Text('Next scan: '),
            Text('Previous upload: '),
            Text('Next upload: '),
            Text('Total measurements: '),
            Text('Unuploaded measurements: '),
          ],
        ),
      ),
    );
  }

}