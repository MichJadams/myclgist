import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class _BlueScannerState extends State<BlueScanner> {
  final Map<String, ScanResult> foundDevices = {};

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () async {
            for (final device in foundDevices.values) {
              final ad = device.advertisementData;

              if (ad.manufacturerData.isEmpty) {
                continue;
              }
              final entry = ad.manufacturerData.entries.first;

              final int companyCode = entry.key;
              final Uint8List manufacturerBytes = Uint8List.fromList(
                entry.value,
              );

              // Flatten service data if present
              Uint8List? serviceBytes;
              if (ad.serviceData.isNotEmpty) {
                final buffer = <int>[];
                for (final value in ad.serviceData.values) {
                  buffer.addAll(value);
                }
                serviceBytes = Uint8List.fromList(buffer);
              }

              // final companion = BlueDevicesCompanion.insert(
              //   manufacturerData: manufacturerBytes,
              //   companyCode: companyCode,
              //   connectable: ad.connectable,
              //   serviceData: serviceBytes != null
              //       ? drift.Value(serviceBytes)
              //       : const drift.Value.absent(),
              // );

              // await db.into(db.blueDevices).insert(companion);

              setState(() {
                foundDevices.clear();
              });
            }
            // save data here
          },
          child: Text('save scan results'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () async {
            await [
              Permission.bluetoothScan,
              Permission.bluetoothConnect,
              Permission.locationWhenInUse,
            ].request();

            await blueScan();
          },
          child: Text('Scan'),
        ),
        Column(
          children: foundDevices.isEmpty
              ? const [Text('no devices found yet')]
              : foundDevices.entries
                    .map(
                      (device) => SelectableText(
                        '${device.value.device.remoteId.toString()} -> ${device.value.advertisementData.serviceUuids}',
                      ),
                    )
                    .toList(),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

Future<Map<String, ScanResult>> blueScan() async {
  final Map<String, ScanResult> foundDevices = {};

  if (await FlutterBluePlus.isSupported == false) {
    return <String, ScanResult>{};
  }

  try {
    await FlutterBluePlus.adapterState
        .where((state) => state == BluetoothAdapterState.on)
        .first
        .timeout(const Duration(seconds: 5));
  } on TimeoutException {
    return <String, ScanResult>{};
  }

  var subscription = FlutterBluePlus.scanResults.listen((results) {
    if (results.isNotEmpty) {
      for (final r in results) {
        final id = r.device.remoteId.toString();
        if (!foundDevices.containsKey(id)) {
          // print('---------------------------');

          // final adv = r.advertisementData;
          // final manufacturerData = adv.manufacturerData.entries
          //     .map(
          //       (e) =>
          //           'ID: ${e.key}, Data: ${e.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
          //     )
          //     .join('; ');

          // print(
          //   '${r.device.remoteId}: "${adv.advName}"\n'
          //   'Service UUIDs: ${adv.serviceUuids.join(', ')}\n'
          //   'Manufacturer Data: $manufacturerData',
          // );

          // print('---------------------------');

          foundDevices[id] = r;
        }
      }
    }
  }, onError: (e) => print(e));

  await FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));
  await FlutterBluePlus.isScanning.where((val) => val == false).first;

  subscription.cancel();
  return foundDevices;
}

class BlueScanner extends StatefulWidget {
  const BlueScanner({super.key});

  @override
  State<BlueScanner> createState() => _BlueScannerState();
}
