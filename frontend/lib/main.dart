import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/customer/app_layout.dart';
import 'presentation/screens/customer/customer_settings_screen.dart';
import 'presentation/screens/customer/customer_detail_screen.dart';
import 'presentation/screens/customer/customer_cart_screen.dart';
import 'presentation/screens/customer/customer_explore_screen.dart';
import 'presentation/screens/customer/customer_rewards_screen.dart';
import 'presentation/screens/customer/customer_eco_impact_screen.dart';
import 'presentation/screens/customer/customer_notifications_screen.dart';
import 'presentation/screens/customer/customer_all_deals_screen.dart';
import 'presentation/screens/customer/customer_all_restaurants_screen.dart';

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
      theme: AppTheme.customerTheme, 
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/preferences': (context) => const PreferencesScreen(),
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
      },
    );
  }
}