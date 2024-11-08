import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ibadah_v2/models/salah_times_provider.dart';
import 'package:intl/intl.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salah Times'),
      ),
      body: salahTimesAsync.when(
        data: (salahTimes) {
          final dateFormatter = DateFormat.yMMMMEEEEd();
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Prayer Times for ${salahTimes.location}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Date: ${dateFormatter.format(salahTimes.date)}',
                ),
                const SizedBox(height: 20),
                Text('Fajr: ${salahTimes.fajr}'),
                Text('Sunrise: ${salahTimes.sunrise}'),
                Text('Dhuhr: ${salahTimes.dhuhr}'),
                Text('Asr: ${salahTimes.asr}'),
                Text('Maghrib: ${salahTimes.maghrib}'),
                Text('Isha: ${salahTimes.isha}'),
              ],
            ),
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
