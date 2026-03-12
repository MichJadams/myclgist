import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:whote_is_there/Fungus/fungus_base.dart';
import 'package:whote_is_there/Fungus/fungus_state.dart';
import 'package:whote_is_there/db/app_database.dart';
import 'package:whote_is_there/db/providers/fungus_provider.dart';
import 'package:whote_is_there/main.dart';
import 'package:whote_is_there/terrarium/fungus_dish.dart';

class InvintoryView extends StatelessWidget {
  const InvintoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: InvintoryPage(),
        ),
      ),
    );
  }
}

class InvintoryPage extends StatelessWidget {
  const InvintoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            context.read<FungusProvider>().getAllFungusAsJson().then(
              (json) => Clipboard.setData(ClipboardData(text: json)),
            );
          },
          child: Text("copy collection to clipboard"),
        ),
        Text(
          'Invintory',
          style: GoogleFonts.rajdhani(
            fontSize: 46,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            height: 1.1,
            color: Colors.orangeAccent,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: const Color.fromARGB(255, 191, 245, 13),
              ),
              Shadow(blurRadius: 20, color: Colors.deepOrange),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ExvacatorPage(),
              ),
            );
          },
          child: Text("back"),
        ),
        TextButton(
          onPressed: () {
            context.read<FungusProvider>().returnAllToSeedbox();
          },
          child: Text("Return to Seedbox"),
        ),
        Expanded(
          flex: 2,
          child: FungusDishView(),
        ),
      ],
    );
  }
}

String fungusToJson(Fungus fungus) {
  return '''
  {
    "id": ${fungus.id},
    "name": "${fungus.name}",
    "invintoryIndex": ${fungus.invintoryIndex},
    "isNew": ${fungus.isNew},
    "perX": ${fungus.perX},
    "perY": ${fungus.perY},
    "color": ${fungus.color},
    "remoteId": "${fungus.remoteId}",
    "platformName": "${fungus.platformName}",
    "serviceData": "${fungus.serviceData}",
    "spottedTime": "${fungus.spottedTime}"
  }
  ''';
}

