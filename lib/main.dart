import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ibadah_v2/models/theme_provider.dart';
import 'package:ibadah_v2/screens/home.dart';
import 'package:ibadah_v2/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorSchemeSeed = ref.watch(colorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode == ThemeModeOption.light
          ? ThemeMode.light
          : themeMode == ThemeModeOption.dark
              ? ThemeMode.dark
              : ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorSchemeSeed),
        useMaterial3: true,
        fontFamily: GoogleFonts.reemKufi().fontFamily,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorSchemeSeed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.reemKufi().fontFamily,
      ),
      home: const Home(),
    );
  }
}
