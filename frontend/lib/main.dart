import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/customer/app_layout.dart';
import 'presentation/screens/customer/customer_settings_screen.dart';

// --- Temporary Stubs for Prototype Routes ---
class StubScreen extends StatelessWidget {
  final String title;
  const StubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page\n(Coming Soon)', textAlign: TextAlign.center)),
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.customerTheme, // Applies your new global CSS variables
      initialRoute: '/auth',
      routes: {
        // --- AUTH & ONBOARDING ---
        '/auth': (context) => const AuthScreen(),
        '/preferences': (context) => const PreferencesScreen(),

        // --- CUSTOMER FLOWS (Wrapped in Bottom Nav) ---
        '/feed': (context) => const AppLayout(), 
        
        // --- SECONDARY SCREENS ---
        '/explore': (context) => const StubScreen(title: 'Explore Deals'),
        '/cart': (context) => const StubScreen(title: 'My Cart'),
        '/rewards': (context) => const StubScreen(title: 'Rewards'),
        '/notifications': (context) => const StubScreen(title: 'Notifications'),
        '/eco-impact': (context) => const StubScreen(title: 'Eco Impact'),
        '/all-deals': (context) => const StubScreen(title: 'All Deals'),
        '/all-restaurants': (context) => const StubScreen(title: 'Nearby Restaurants'),
        '/settings': (context) => const CustomerSettingsScreen(),
        
        // --- FALLBACK ---
        '/': (context) => const AuthScreen(),
      },
    );
  }
}