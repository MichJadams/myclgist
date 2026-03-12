import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionHandler extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  final Widget child;

  const BluetoothPermissionHandler({
    super.key,
    this.onPermissionsGranted,
    required this.child,
  });

  @override
  State<BluetoothPermissionHandler> createState() =>
      _BluetoothPermissionHandlerState();
}

class _BluetoothPermissionHandlerState
    extends State<BluetoothPermissionHandler> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check permissions
    final scanStatus = await Permission.bluetoothScan.status;
    final advertiseStatus = await Permission.bluetoothAdvertise.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    setState(() {
      _permissionsGranted =
          scanStatus.isGranted &&
          advertiseStatus.isGranted &&
          locationStatus.isGranted;
    });

    if (!_permissionsGranted) {
      _requestPermissions();
    } else {
      widget.onPermissionsGranted?.call();
    }
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    setState(() {
      _permissionsGranted = allGranted;
    });

    if (allGranted) {
      widget.onPermissionsGranted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionsGranted) {
      return widget.child; // show the app instead of SizedBox.shrink()
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bluetooth permissions are required for scanning and advertising.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _requestPermissions,
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }
}
