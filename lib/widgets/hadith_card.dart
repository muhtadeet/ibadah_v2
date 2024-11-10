import 'package:flutter/material.dart';
import 'package:ibadah_v2/models/salah_times_provider.dart';

class HadithCard extends StatelessWidget {
  const HadithCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchHadith(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final hadithText = snapshot.data ?? 'No hadith available at the moment.';
          final colorScheme = Theme.of(context).colorScheme;
          
          return Card(
            elevation: 5,
            color: colorScheme.surfaceBright,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Hadith',
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hadithText,
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                      height: 2,
                      wordSpacing: 3,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}