import 'dart:async';
import 'package:flutter/material.dart';
import '../models/city.dart';
import '../widgets/clock_card.dart';

class WorldClockPage extends StatefulWidget {
  final bool german;

  const WorldClockPage({
    super.key,
    required this.german,
  });

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  DateTime currentTime = DateTime.now();
  late Timer timer;

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
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.german ? 'Weltuhr' : 'World Clock',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int columns = 1;

              if (constraints.maxWidth >= 1000) {
                columns = 3;
              } else if (constraints.maxWidth >= 560) {
                columns = 2;
              }

              const gap = 16.0;

              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) /
                      columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: majorCities.map((city) {
                  return SizedBox(
                    width: cardWidth,
                    child: ClockCard(
                      city: city,
                      german: widget.german,
                      currentTime: currentTime,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}