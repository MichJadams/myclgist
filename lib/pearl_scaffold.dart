import 'package:flutter/material.dart';
import 'package:whote_is_there/models/perl_data.dart';
import 'package:whote_is_there/pearl.dart';
import 'package:whote_is_there/terrarium/invintory_page.dart';

class PearlScaffold extends StatelessWidget {
  final Set<int> placedPearls;
  const PearlScaffold({super.key, required this.placedPearls});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxHeight / 2;

        return Row(
          children: [
            Perl(
              size: maxWidth,
              data: PearlData(1),
              isPlaced: placedPearls.contains(1),
            ),
            Perl(
              size: maxWidth,
              data: PearlData(2),
              isPlaced: placedPearls.contains(2),
            ),
            Perl(
              size: maxWidth,
              data: PearlData(3),
              isPlaced: placedPearls.contains(3),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Invintory'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const InvintoryView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

