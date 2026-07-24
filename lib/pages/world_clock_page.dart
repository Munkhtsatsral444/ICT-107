import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/city.dart';
import '../widgets/clock_card.dart';

class WorldClockPage extends StatefulWidget {
  final bool german;

  const WorldClockPage({
    super.key,
    required this.german,
  });

  @override
  State<WorldClockPage> createState() {
    return _WorldClockPageState();
  }
}

class _WorldClockPageState
    extends State<WorldClockPage> {
  DateTime currentTime = DateTime.now();
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {
            currentTime = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(
            mobile ? 18 : 28,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.german
                    ? 'Weltuhr'
                    : 'World Clock',
                style:
                    GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.german
                    ? 'Aktuelle Uhrzeit in internationalen Städten'
                    : 'Current time in international cities',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.60),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder:
                    (context, gridConstraints) {
                  int columns = 1;

                  if (gridConstraints.maxWidth >=
                      1050) {
                    columns = 3;
                  } else if (gridConstraints
                          .maxWidth >=
                      620) {
                    columns = 2;
                  }

                  const gap = 14.0;

                  final cardWidth =
                      (gridConstraints.maxWidth -
                              gap * (columns - 1)) /
                          columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: majorCities.map(
                      (city) {
                        return SizedBox(
                          width: cardWidth,
                          child: ClockCard(
                            city: city,
                            german:
                                widget.german,
                            currentTime:
                                currentTime,
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}