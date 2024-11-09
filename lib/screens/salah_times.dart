import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ibadah_v2/models/salah_times_provider.dart';
// import 'package:intl/intl.dart';

class SalahTimesPage extends ConsumerStatefulWidget {
  const SalahTimesPage({super.key});

  @override
  ConsumerState<SalahTimesPage> createState() => _SalahTimesPageState();
}

class _SalahTimesPageState extends ConsumerState<SalahTimesPage> {
  @override
  void initState() {
    super.initState();

    ref.read(salahTimesProvider.notifier).loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    final salahTimesAsync = ref.watch(salahTimesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.onSecondary,
        forceMaterialTransparency: true,
        title: Text(
          'Salah Times',
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        titleSpacing: 25,
      ),
      body: salahTimesAsync.when(
        data: (salahTimes) {
          // final dateFormatter = DateFormat.yMMMMEEEEd();
          return Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                        color: colorScheme.onTertiaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Fajr',
                          style: TextStyle(fontSize: 16),
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   'Sunrise',
                        //   style: TextStyle(fontSize: 16),
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Dhuhr',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Asr',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Maghrib',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Isha',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Qiyam',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          salahTimes.fajr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Text(
                        //   salahTimes.sunrise,
                        //   style: const TextStyle(fontSize: 16),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          salahTimes.dhuhr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          salahTimes.asr,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          salahTimes.maghrib,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          salahTimes.isha,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          salahTimes.qiyam,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: colorScheme.primary.withOpacity(0.2),
                indent: 100,
                endIndent: 100,
                height: 0,
                thickness: 1,
              ),
              const SizedBox(
                height: 40,
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Sunrise',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          salahTimes.sunrise,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      color: colorScheme.onSurface,
                      indent: 10,
                      endIndent: 10,
                      thickness: 1,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Sunset',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          salahTimes.maghrib,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            'Error Loading Salah Times: $error',
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
