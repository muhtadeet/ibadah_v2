import 'dart:convert';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:ibadah_v2/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SalahTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String qiyam;
  final String location;
  final DateTime date;
  final double qiblaDirection;

  const SalahTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.qiyam,
    required this.location,
    required this.date,
    required this.qiblaDirection,
  });

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'qiyam': qiyam,
      'location': location,
      'date': date.toIso8601String(),
      'qiblaDirection': qiblaDirection,
    };
  }

  factory SalahTimes.fromJson(Map<String, dynamic> json) {
    return SalahTimes(
      fajr: json['fajr'],
      sunrise: json['sunrise'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
      qiyam: json['qiyam'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      qiblaDirection: json['qiblaDirection'],
    );
  }
}

class SalahTimesNotifier extends StateNotifier<AsyncValue<SalahTimes>> {
  final NotificationService _notificationService = NotificationService();
  final logger = Logger();

  SalahTimesNotifier() : super(const AsyncValue.loading()) {
    _initTimezone();
    _initNotifications();
    loadPrayerTimes();
  }

  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
  }

  Future<void> _initNotifications() async {
    await _notificationService.init();
  }

  Future<void> loadPrayerTimes() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('salahTimes');

      if (savedData != null) {
        final data = jsonDecode(savedData);
        state = AsyncValue.data(SalahTimes.fromJson(data));
      } else {
        await fetchAndSavePrayerTimes();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchAndSavePrayerTimes() async {
    try {
      if (await _requestLocationPermission()) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        );

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
        final sunnahTimes = SunnahTimes(prayerTimes);

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        String place =
            '${placemarks.first.locality},  ${placemarks.first.country}';

        final format = DateFormat.jm();
        double qiblaDirection = await _getQiblaDirection(position);

        final salahTimes = SalahTimes(
          fajr: format
              .format(tz.TZDateTime.from(prayerTimes.fajr!, location))
              .toString(),
          sunrise: format
              .format(tz.TZDateTime.from(prayerTimes.sunrise!, location))
              .toString(),
          dhuhr: format
              .format(tz.TZDateTime.from(prayerTimes.dhuhr!, location))
              .toString(),
          asr: format
              .format(tz.TZDateTime.from(prayerTimes.asr!, location))
              .toString(),
          maghrib: format
              .format(tz.TZDateTime.from(prayerTimes.maghrib!, location))
              .toString(),
          isha: format
              .format(tz.TZDateTime.from(prayerTimes.isha!, location))
              .toString(),
          qiyam: format
              .format(
                  tz.TZDateTime.from(sunnahTimes.lastThirdOfTheNight, location))
              .toString(),
          location: place,
          date: DateTime.now(),
          qiblaDirection: qiblaDirection,
        );

        state = AsyncValue.data(salahTimes);
        saveToLocalStorage(salahTimes);

        await _scheduleNotifications(salahTimes);
      } else {
        state =
            AsyncValue.error("Location permission denied.", StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _scheduleNotifications(SalahTimes salahTimes) async {
    // Map prayer times to a Map<String, String> as required by NotificationService
    final Map<String, String> prayerTimesMap = {
      'Fajr': salahTimes.fajr,
      'Sunrise': salahTimes.sunrise,
      'Dhuhr': salahTimes.dhuhr,
      'Asr': salahTimes.asr,
      'Maghrib': salahTimes.maghrib,
      'Isha': salahTimes.isha,
      'Qiyam': salahTimes.qiyam,
    };

    try {
      // Schedule prayer notifications
      await _notificationService.schedulePrayerNotifications(prayerTimesMap);
    } catch (e) {
      // Log the error if scheduling fails
      logger.e("Error scheduling prayer notifications: $e");
    }
  }

  Future<void> saveToLocalStorage(SalahTimes data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(data.toJson());
    await prefs.setString('salahTimes', jsonData);
  }

  Future<double> _getQiblaDirection(Position position) async {
    Coordinates userCoordinates =
        Coordinates(position.latitude, position.longitude);

    var qibla = Qibla.qibla(userCoordinates);
    return qibla;
  }

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }
}

Future<String> fetchHadith() async {
  final prefs = await SharedPreferences.getInstance();
  final currentDate = DateTime.now()
      .toIso8601String()
      .substring(0, 10); // Format date as YYYY-MM-DD

  // Retrieve cached hadith and date from SharedPreferences
  final cachedHadith = prefs.getString('dailyHadith');
  final cachedDate = prefs.getString('hadithDate');

  // If cached hadith exists for today's date, use it
  if (cachedHadith != null && cachedDate == currentDate) {
    return _formatHadith(cachedHadith); // Format cached hadith
  } else {
    try {
      // Fetch hadith from the API
      final response = await http.get(
          Uri.parse('https://random-hadith-generator.vercel.app/bukhari/'));

      if (response.statusCode == 200) {
        // Parse JSON response
        final data = jsonDecode(response.body);

        // Check if 'data' contains 'hadith_english' and is a valid string
        if (data is Map &&
            data['data'] is Map &&
            data['data']['hadith_english'] is String) {
          final hadith = data['data']['hadith_english'];

          // Cache the hadith and today's date
          await prefs.setString('dailyHadith', hadith);
          await prefs.setString('hadithDate', currentDate);

          return _formatHadith(hadith); // Return formatted hadith
        } else {
          return 'Hadith not available at this time.';
        }
      } else {
        return 'Error: (Status code: ${response.statusCode}).';
      }
    } catch (e) {
      return 'Network error: Unable to fetch hadith.';
    }
  }
}

String _formatHadith(String hadith) {
  // Remove any extra whitespace and newlines, replacing them with a single space
  final cleanedHadith = hadith.replaceAll(RegExp(r'\s+'), ' ').trim();
  return cleanedHadith;
}

final salahTimesProvider =
    StateNotifierProvider<SalahTimesNotifier, AsyncValue<SalahTimes>>((ref) {
  return SalahTimesNotifier();
});
