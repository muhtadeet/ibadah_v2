import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ibadah_v2/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary),
          useMaterial3: true,
          fontFamily: GoogleFonts.reemKufi().fontFamily),
      darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.reemKufi().fontFamily,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
              brightness: Brightness.dark)),
      home: const Home(),
    );
  }
}
