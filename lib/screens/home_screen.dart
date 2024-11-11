import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ibadah_v2/models/salah_times_provider.dart';
import 'package:ibadah_v2/widgets/hadith_card.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late StreamSubscription<int> _countdownSubscription;
  String countdownText = '';

  @override
  void initState() {
    super.initState();

    ref.read(salahTimesProvider.notifier).loadPrayerTimes();
    _countdownSubscription =
        Stream.periodic(const Duration(seconds: 1), _calculateRemainingTime)
            .listen(_updateCountdown);
  }

  @override
  void dispose() {
    _countdownSubscription.cancel();
    super.dispose();
  }

  int _calculateRemainingTime(int _) {
    final salahTimesAsync = ref.read(salahTimesProvider);
    salahTimesAsync.whenData((salahTimes) {
      final now = DateTime.now();
      final currentSeconds = now.hour * 3600 + now.minute * 60 + now.second;

      int timeToSeconds(String time) {
        DateTime dateTime;
        if (time.contains('AM') || time.contains('PM')) {
          dateTime = DateFormat.jm().parse(time);
        } else {
          dateTime = DateFormat('HH:mm').parse(time);
        }
        return dateTime.hour * 3600 + dateTime.minute * 60 + dateTime.second;
      }

      final fajrTime = timeToSeconds(salahTimes.fajr);
      final sunriseTime = timeToSeconds(salahTimes.sunrise);
      final dhuhrTime = timeToSeconds(salahTimes.dhuhr);
      final asrTime = timeToSeconds(salahTimes.asr);
      final maghribTime = timeToSeconds(salahTimes.maghrib);
      final ishaTime = timeToSeconds(salahTimes.isha);
      final qiyamTime = timeToSeconds(salahTimes.qiyam);

      int nextPrayerTime = 0;
      int remainingSeconds = 0;

      // If current time is after Isha and before midnight
      if (currentSeconds >= ishaTime) {
        // Calculate seconds until midnight
        final secondsUntilMidnight = 24 * 3600 - currentSeconds;
        // Add seconds from midnight until Qiyam
        remainingSeconds = secondsUntilMidnight + qiyamTime;
      }
      // If current time is after midnight but before Qiyam
      else if (currentSeconds < qiyamTime) {
        remainingSeconds = qiyamTime - currentSeconds;
      }
      // For all other prayer times
      else {
        if (currentSeconds < fajrTime) {
          nextPrayerTime = fajrTime;
        } else if (currentSeconds < sunriseTime) {
          nextPrayerTime = sunriseTime;
        } else if (currentSeconds < dhuhrTime) {
          nextPrayerTime = dhuhrTime;
        } else if (currentSeconds < asrTime) {
          nextPrayerTime = asrTime;
        } else if (currentSeconds < maghribTime) {
          nextPrayerTime = maghribTime;
        } else if (currentSeconds < ishaTime) {
          nextPrayerTime = ishaTime;
        }
        remainingSeconds = nextPrayerTime - currentSeconds;
      }
      
      final remainingDuration = Duration(seconds: remainingSeconds);

      setState(() {
        countdownText = _formatDuration(remainingDuration);
      });
    });

    return 0;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}         -         ${minutes.toString().padLeft(2, '0')}         -         ${seconds.toString().padLeft(2, '0')}';
  }

  void _updateCountdown(int data) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final salahTimesAsync = ref.watch(salahTimesProvider);

    String currentSalahName = "Loading...";
    String upcomingSalahName = "Loading...";
    String upcomingSalahTime = "Loading...";

    salahTimesAsync.whenData((salahTimes) {
      final now = DateTime.now();
      final currentSeconds = now.hour * 3600 + now.minute * 60;

      int timeToSeconds(String time) {
        DateTime dateTime;
        if (time.contains('AM') || time.contains('PM')) {
          dateTime = DateFormat.jm().parse(time);
        } else {
          dateTime = DateFormat('HH:mm').parse(time);
        }
        return dateTime.hour * 3600 + dateTime.minute * 60;
      }

      final fajrTime = timeToSeconds(salahTimes.fajr);
      final sunriseTime = timeToSeconds(salahTimes.sunrise);
      final dhuhrTime = timeToSeconds(salahTimes.dhuhr);
      final asrTime = timeToSeconds(salahTimes.asr);
      final maghribTime = timeToSeconds(salahTimes.maghrib);
      final ishaTime = timeToSeconds(salahTimes.isha);
      final qiyamTime = timeToSeconds(salahTimes.qiyam);

      if (currentSeconds < fajrTime && currentSeconds >= qiyamTime) {
        currentSalahName = 'Qiyam';
        upcomingSalahName = 'Fajr';
        upcomingSalahTime = salahTimes.fajr;
      } else if (currentSeconds >= fajrTime && currentSeconds < sunriseTime) {
        currentSalahName = 'Fajr';
        upcomingSalahName = 'Sunrise';
        upcomingSalahTime = salahTimes.sunrise;
      } else if (currentSeconds >= sunriseTime && currentSeconds < dhuhrTime) {
        currentSalahName = 'A Fresh Start';
        upcomingSalahName = 'Dhuhr';
        upcomingSalahTime = salahTimes.dhuhr;
      } else if (currentSeconds >= dhuhrTime && currentSeconds < asrTime) {
        currentSalahName = 'Dhuhr';
        upcomingSalahName = 'Asr';
        upcomingSalahTime = salahTimes.asr;
      } else if (currentSeconds >= asrTime && currentSeconds < maghribTime) {
        currentSalahName = 'Asr';
        upcomingSalahName = 'Maghrib';
        upcomingSalahTime = salahTimes.maghrib;
      } else if (currentSeconds >= maghribTime && currentSeconds < ishaTime) {
        currentSalahName = 'Maghrib';
        upcomingSalahName = 'Isha';
        upcomingSalahTime = salahTimes.isha;
      } else if (currentSeconds >= ishaTime || currentSeconds < qiyamTime) {
        currentSalahName = 'Isha';
        upcomingSalahName = 'Qiyam';
        upcomingSalahTime = salahTimes.qiyam;
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    HijriCalendar today = HijriCalendar.now();

    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      appBar: AppBar(
        elevation: 5,
        forceMaterialTransparency: true,
        shadowColor: colorScheme.surfaceContainer,
        toolbarHeight: 80,
        backgroundColor: colorScheme.onSecondary,
        title: Text(
          'Ibadah',
          style: TextStyle(
            fontSize: 24,
            color: colorScheme.primaryFixedDim,
          ),
        ),
        titleSpacing: 25,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: salahTimesAsync.when(
              data: (salahTimes) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.goal,
                          color: colorScheme.onTertiaryContainer,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          salahTimes.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Column(
                      children: [
                        Text(
                          "${today.longMonthName}    ${today.hDay},    ${today.hYear} AH",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.primaryFixed,
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
                            backgroundColor: colorScheme.tertiary)));
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                // Changed from Row to Column
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Time for',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentSalahName,
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Next up is $upcomingSalahName at $upcomingSalahTime',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'After',
                    style: TextStyle(
                      color: colorScheme.primaryFixed,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    countdownText,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Hours                                Mins                                Secs ',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Divider(
                      color: colorScheme.primary.withOpacity(0.2),
                      indent: 85,
                      endIndent: 85,
                      height: 0,
                      thickness: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 50,
                    ),
                    child: HadithCard(key: Key('dailyHadithCard')),
                  ),
                ],
              ),
            ),
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
    );
  }

  String currentSalah() {
    final salahTimes = ref.watch(salahTimesProvider).value;
    if (salahTimes == null) return 'Loading...';

    final now = DateTime.now();
    final currentSeconds = now.hour * 3600 + now.minute * 60;

    int timeToSeconds(String time) {
      DateTime dateTime;

      if (time.contains('AM') || time.contains('PM')) {
        dateTime = DateFormat.jm().parse(time);
      } else {
        dateTime = DateFormat('HH:mm').parse(time);
      }

      return dateTime.hour * 3600 + dateTime.minute * 60;
    }

    final fajrTime = timeToSeconds(salahTimes.fajr);
    final sunriseTime = timeToSeconds(salahTimes.sunrise);
    final dhuhrTime = timeToSeconds(salahTimes.dhuhr);
    final asrTime = timeToSeconds(salahTimes.asr);
    final maghribTime = timeToSeconds(salahTimes.maghrib);
    final ishaTime = timeToSeconds(salahTimes.isha);
    final qiyamTime = timeToSeconds(salahTimes.qiyam);

    if (currentSeconds < fajrTime && currentSeconds > ishaTime) {
      return 'Qiyam';
    } else if (currentSeconds >= fajrTime && currentSeconds < sunriseTime) {
      return 'Fajr';
    } else if (currentSeconds >= sunriseTime && currentSeconds < dhuhrTime) {
      return 'Sunrise';
    } else if (currentSeconds >= dhuhrTime && currentSeconds < asrTime) {
      return 'Dhuhr';
    } else if (currentSeconds >= asrTime && currentSeconds < maghribTime) {
      return 'Asr';
    } else if (currentSeconds >= maghribTime && currentSeconds < ishaTime) {
      return 'Maghrib';
    } else if (currentSeconds >= ishaTime || currentSeconds < qiyamTime) {
      return 'Isha';
    } else {
      return 'Unknown';
    }
  }

  String upcomingSalah() {
    final salahTimes = ref.watch(salahTimesProvider).value;
    if (salahTimes == null) return 'Loading...';

    final now = DateTime.now();
    final currentSeconds = now.hour * 3600 + now.minute * 60;

    int timeToSeconds(String time) {
      DateTime dateTime;

      if (time.contains('AM') || time.contains('PM')) {
        dateTime = DateFormat.jm().parse(time);
      } else {
        dateTime = DateFormat('HH:mm').parse(time);
      }

      return dateTime.hour * 3600 + dateTime.minute * 60;
    }

    final fajrTime = timeToSeconds(salahTimes.fajr);
    final sunriseTime = timeToSeconds(salahTimes.sunrise);
    final dhuhrTime = timeToSeconds(salahTimes.dhuhr);
    final asrTime = timeToSeconds(salahTimes.asr);
    final maghribTime = timeToSeconds(salahTimes.maghrib);
    final ishaTime = timeToSeconds(salahTimes.isha);
    final qiyamTime = timeToSeconds(salahTimes.qiyam);

    if (currentSeconds < fajrTime && currentSeconds > ishaTime) {
      return 'Fajr';
    } else if (currentSeconds >= fajrTime && currentSeconds < sunriseTime) {
      return 'Sunrise';
    } else if (currentSeconds >= sunriseTime && currentSeconds < dhuhrTime) {
      return 'Dhuhr';
    } else if (currentSeconds >= dhuhrTime && currentSeconds < asrTime) {
      return 'Asr';
    } else if (currentSeconds >= asrTime && currentSeconds < maghribTime) {
      return 'Maghrib';
    } else if (currentSeconds >= maghribTime && currentSeconds < ishaTime) {
      return 'Isha';
    } else if (currentSeconds >= ishaTime || currentSeconds < qiyamTime) {
      return 'Qiyam';
    } else {
      return 'Unknown';
    }
  }

  String upcomingSalahTime() {
    final salahTimes = ref.watch(salahTimesProvider).value;
    if (salahTimes == null) return 'Loading...';

    final now = DateTime.now();
    final currentSeconds = now.hour * 3600 + now.minute * 60;

    int timeToSeconds(String time) {
      DateTime dateTime;

      if (time.contains('AM') || time.contains('PM')) {
        dateTime = DateFormat.jm().parse(time);
      } else {
        dateTime = DateFormat('HH:mm').parse(time);
      }

      return dateTime.hour * 3600 + dateTime.minute * 60;
    }

    final fajrTime = timeToSeconds(salahTimes.fajr);
    final sunriseTime = timeToSeconds(salahTimes.sunrise);
    final dhuhrTime = timeToSeconds(salahTimes.dhuhr);
    final asrTime = timeToSeconds(salahTimes.asr);
    final maghribTime = timeToSeconds(salahTimes.maghrib);
    final ishaTime = timeToSeconds(salahTimes.isha);
    final qiyamTime = timeToSeconds(salahTimes.qiyam);

    if (currentSeconds < fajrTime && currentSeconds > ishaTime) {
      return salahTimes.fajr;
    } else if (currentSeconds >= fajrTime && currentSeconds < sunriseTime) {
      return salahTimes.sunrise;
    } else if (currentSeconds >= sunriseTime && currentSeconds < dhuhrTime) {
      return salahTimes.dhuhr;
    } else if (currentSeconds >= dhuhrTime && currentSeconds < asrTime) {
      return salahTimes.asr;
    } else if (currentSeconds >= asrTime && currentSeconds < maghribTime) {
      return salahTimes.maghrib;
    } else if (currentSeconds >= maghribTime && currentSeconds < ishaTime) {
      return salahTimes.isha;
    } else if (currentSeconds >= ishaTime || currentSeconds < qiyamTime) {
      return salahTimes.qiyam;
    } else {
      return 'Unknown';
    }
  }
}
