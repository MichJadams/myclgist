import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';
import 'package:whote_is_there/PearlFishingContainer.dart';
import 'package:whote_is_there/db/app_database.dart';
import 'package:whote_is_there/db/providers/fungus_provider.dart';
import 'package:whote_is_there/db/providers/stone_provider.dart';
import 'package:whote_is_there/map_canvas_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<FungusProvider>(
            create: (context) => FungusProvider(db: db),
          ),
          ChangeNotifierProvider<StoneProvider>(
            create: (context) => StoneProvider(db: db),
          ),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ExvacatorPage());
  }
}

class ExvacatorPage extends StatefulWidget {
  const ExvacatorPage({super.key});

  @override
  State<ExvacatorPage> createState() => _ExvacatorPage();
}

class _ExvacatorPage extends State<ExvacatorPage> {
  StoneData? selectedStone;

  void onStoneTapped(StoneData stoneData) {
    setState(() {
      selectedStone = stoneData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: PerlFishingContainer(onStoneTapped: onStoneTapped),
              ),
              Expanded(
                flex: 2,
                child: DiggingInformation(stoneData: selectedStone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiggingInformation extends StatelessWidget {
  final StoneData? stoneData;

  const DiggingInformation({super.key, required this.stoneData});

  @override
  Widget build(BuildContext context) {
    print("Selected stone: ${stoneData}");
    if (stoneData != null) {
      return Column(
        children: [
          Text(stoneData!.name),
          SaveButton(stoneData: stoneData!),
          ElevatedButton(
            onPressed: () async {
              await nukeDatabase();
              Phoenix.rebirth(Navigator.of(context).context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Nuke Database'),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Text("No stone selected"),
          ElevatedButton(
            onPressed: () async {
              await nukeDatabase();
              Phoenix.rebirth(Navigator.of(context).context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Nuke Database'),
          )
        ],
      );
    }
  }
}

class SaveButton extends StatelessWidget {
  final StoneData stoneData;
  const SaveButton({super.key, required this.stoneData});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        var existingStone = await context
            .read<StoneProvider>()
            .getStoneByRemoteId(stoneData.remoteId);
        if (existingStone != null) {
          print(
            "Stone with remoteId ${stoneData.remoteId} already exists in the database.",
          );
          return;
        } else {
          await context.read<StoneProvider>().insertStone(stoneData);
          print("Stone saved successfully!");
          final firstOpenInventoryIndex = getFirstOpenInventoryIndex(
            context.read<FungusProvider>().fungi,
          );
          print("First open inventory index: $firstOpenInventoryIndex, fungus added");
          context.read<FungusProvider>().insertFungus(
            FungiCompanion(
              name: Value(stoneData.name),
              invintoryIndex: Value(firstOpenInventoryIndex),
              isNew: Value(true),
              perX: Value(0),
              perY: Value(0),
              color: Value(colorFromMac(stoneData.remoteId).toARGB32()),
              remoteId: Value(stoneData.remoteId),
              platformName: Value(stoneData.platformName),
              serviceData: Value(stoneData.serviceData),
              spottedTime: Value(stoneData.timeStamp),
            ),
          );
        }
      },

      child: Text("Save ${stoneData.remoteId}"),
    );
  }
}

Color colorFromMac(String mac) {
  final parts = mac.replaceAll(':', '');

  final r = int.parse(parts.substring(0, 2), radix: 16);
  final g = int.parse(parts.substring(2, 4), radix: 16);
  final b = int.parse(parts.substring(4, 6), radix: 16);

  return Color.fromARGB(255, r, g, b);
}

int getFirstOpenInventoryIndex(List<FungusState> fungusList) {
  final usedIndexes = fungusList.map((f) => f.inventoryIndex).toSet();

  int index = 0;
  while (usedIndexes.contains(index)) {
    index++;
  }
  return index;
}
