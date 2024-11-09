import 'dart:convert';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        // Load data from local storage
        final data = jsonDecode(savedData);
        state = AsyncValue.data(SalahTimes.fromJson(data));
      } else {
        // Fetch prayer times if no saved data found
        await fetchAndSavePrayerTimes();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchAndSavePrayerTimes() async {
    try {
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
      saveToLocalStorage(salahTimes); // Save data to local storage
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
}

final salahTimesProvider =
    StateNotifierProvider<SalahTimesNotifier, AsyncValue<SalahTimes>>((ref) {
  return SalahTimesNotifier();
});
