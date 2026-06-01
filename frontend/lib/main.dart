import 'package:flutter/material.dart';

// --- Theme ---
import 'core/theme/app_theme.dart';

// --- Customer Screens ---
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/preferences_screen.dart'; // Handles PreferencesScreen
import 'presentation/screens/customer_feed_screen.dart'; // Handles CustomerFeedScreen

class StubScreen extends StatelessWidget {
  final String title;
  const StubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page\n(Coming Soon)')),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DailyTagamApp());
}

class DailyTagamApp extends StatelessWidget {
  const DailyTagamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tagam',
      theme: AppTheme.customerTheme,
      initialRoute: '/auth',
      routes: {
        // --- AUTH & ONBOARDING ---
        '/auth': (context) => const AuthScreen(),
        '/preferences': (context) => const PreferencesScreen(),

        // --- CUSTOMER FLOWS ---
        '/feed': (context) => const CustomerFeedScreen(),
        '/explore': (context) => const StubScreen(title: 'Explore Deals'),
        
        // --- ROOT FALLBACK ---
        '/': (context) => const AuthScreen(),
      },
    );
  }
}