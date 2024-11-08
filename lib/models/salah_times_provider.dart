import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:ibadah_v2/services/notification_service.dart';
import 'package:intl/intl.dart';

class SalahTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String location;
  final DateTime date;

  const SalahTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.location,
    required this.date,
  });

  SalahTimes copyWith({
    String? fajr,
    String? sunrise,
    String? dhuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? location,
    DateTime? date,
  }) {
    return SalahTimes(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      location: location ?? this.location,
      date: date ?? this.date,
    );
  }
}

class SalahTimesNotifier extends StateNotifier<AsyncValue<SalahTimes>> {
  final NotificationService _notificationService = NotificationService();

  SalahTimesNotifier() : super(const AsyncValue.loading()) {
    _initTimezone();
    _initNotifications();
  }

  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
  }

  Future<void> _initNotifications() async {
    await _notificationService.init();
  }

  Future<void> loadPrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      // final locationName = '${position.latitude}, ${position.longitude}';
      final location = tz.getLocation('Asia/Dhaka');

      DateTime date = tz.TZDateTime.from(DateTime.now(), location);
      Coordinates coordinates =
          Coordinates(position.latitude, position.longitude);
      CalculationParameters params = CalculationMethod.muslimWorldLeague();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String place =
          '${placemarks.first.locality}, ${placemarks.first.country}';

      state = AsyncValue.data(SalahTimes(
          fajr: tz.TZDateTime.from(prayerTimes.fajr!, location).toString(),
          sunrise:
              tz.TZDateTime.from(prayerTimes.sunrise!, location).toString(),
          dhuhr: tz.TZDateTime.from(prayerTimes.dhuhr!, location).toString(),
          asr: tz.TZDateTime.from(prayerTimes.asr!, location).toString(),
          maghrib:
              tz.TZDateTime.from(prayerTimes.maghrib!, location).toString(),
          isha: tz.TZDateTime.from(prayerTimes.isha!, location).toString(),
          location: place,
          date: DateTime.now()));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final salahTimesProvider =
    StateNotifierProvider<SalahTimesNotifier, AsyncValue<SalahTimes>>((ref) {
  return SalahTimesNotifier();
});

final currentSalahProvider = Provider<String>((ref) {
  final prayerTimers = ref.watch(salahTimesProvider);
  final now = DateTime.now();
  final currentTime = DateFormat('HH:mm').format(now);

  final prayers = {
    'Fajr': prayerTimers.value?.fajr,
    'Sunrise': prayerTimers.value?.sunrise,
    'Dhuhr': prayerTimers.value?.dhuhr,
    'Asr': prayerTimers.value?.asr,
    'Maghrib': prayerTimers.value?.maghrib,
    'Isha': prayerTimers.value?.isha,
  };

  String current = 'Isha';
  for (var prayer in prayers.entries) {
    if (prayer.value != null && currentTime.compareTo(prayer.value!) <= 0) {
      current = prayer.key;
      break;
    }
  }

  return current;
});
