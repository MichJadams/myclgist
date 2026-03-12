import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:permission_handler/permission_handler.dart';

class Advertise extends StatelessWidget {
  const Advertise({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () async {
                        await [
              Permission.bluetoothAdvertise,
            ].request();
            await advertiseServiceUuid();
          },
          child: Text('advertise'),
        ),
      ],
    );
  }
}

Future<void> advertiseServiceUuid() async {
  final pm = PeripheralManager();

final manufacturerDataList = [
  ManufacturerSpecificData(
    id: 0xFFFE, // Replace with your Bluetooth company ID
    data: Uint8List.fromList(utf8.encode('hello')), // Your payload
  ),
];


  final advertiseData = Advertisement(
    manufacturerSpecificData: manufacturerDataList,
  );

  pm.stateChanged.listen((state) async {
    print('[FLUTTER_BLE_PLUGIN] Bluetooth state: ${state.state}');
    
    await pm.startAdvertising(advertiseData);
    print('[FLUTTER_BLE_PLUGIN] Started advertising "hello" with Company ID 0xFFFE');

    await Future.delayed(const Duration(seconds: 5));
    await pm.stopAdvertising();
    print('[FLUTTER_BLE_PLUGIN] Stopped advertising');

  });
}
