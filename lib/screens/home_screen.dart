import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ibadah_v2/models/salah_times_provider.dart';
// import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(salahTimesProvider.notifier).loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    final salahTimesAsync = ref.watch(salahTimesProvider);
    final currentSalah = ref.watch(currentSalahProvider);

    final colorScheme = Theme.of(context).colorScheme;
    HijriCalendar today = HijriCalendar.now();

    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.onSecondary,
        title: Text(
          'Ibadah',
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        titleSpacing: 25,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: salahTimesAsync.when(
              data: (salahTimes) {
                // final dateFormatter = DateFormat.yMMMMEEEEd();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.asterisk,
                          color: colorScheme.onTertiaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          salahTimes.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "${today.hDay}    ${today.longMonthName}    ${today.hYear}",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () {
                Center(
                    child: Text('Loading...',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                        )));
                return null;
              },
              error: (error, stackTrace) => const Text(
                'Error',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: salahTimesAsync.when(
        data: (salahTimes) {
          return Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentSalah,
                  style: TextStyle(
                    color: colorScheme.tertiary,
                    fontSize: 42,
                  ),
                ),
              ],
            ),
          ]);
        },
        loading: () {
          Center(
              child: Text('Loading...',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                  )));
          return null;
        },
        error: (error, stackTrace) => const Text(
          'Error',
          style: TextStyle(
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
