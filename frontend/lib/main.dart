import 'package:daily_tagam_frontend/presentation/screens/customer/customer_explore_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/customer/app_layout.dart';
import 'presentation/screens/customer/customer_settings_screen.dart';
import 'presentation/screens/customer/customer_detail_screen.dart';
import 'presentation/screens/customer/customer_cart_screen.dart';
import 'presentation/screens/customer/customer_rewards_screen.dart';
import 'presentation/screens/customer/customer_eco_impact_screen.dart';
import 'presentation/screens/customer/customer_notifications_screen.dart';
import 'presentation/screens/customer/customer_all_deals_screen.dart';
import 'presentation/screens/customer/customer_all_restaurants_screen.dart';

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
        // ignore: equal_keys_in_map
        '/auth': (context) => const AuthScreen(),
        // ignore: equal_keys_in_map
        '/preferences': (context) => const PreferencesScreen(),
        // ignore: equal_keys_in_map
        '/feed': (context) => const AppLayout(),
        '/settings': (context) => const CustomerSettingsScreen(),
        '/detail': (context) => const CustomerDetailScreen(),
        '/cart': (context) => const CustomerCartScreen(),
        '/explore': (context) => const CustomerExploreScreen(),
        '/rewards': (context) => const CustomerRewardsScreen(),
        '/eco-impact': (context) => const CustomerEcoImpactScreen(),
        '/notifications': (context) => const CustomerNotificationsScreen(),
        '/all-deals': (context) => const CustomerAllDealsScreen(),
        '/all-restaurants': (context) => const CustomerAllRestaurantsScreen(),
        
        // --- FALLBACK ---
        '/': (context) => const AuthScreen(),
      },
    );
  }
}