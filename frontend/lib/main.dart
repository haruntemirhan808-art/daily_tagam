import 'package:flutter/material.dart';
import 'presentation/screens/auth_screen.dart';
import 'core/network/api_client.dart';
import 'data/repositories/offer_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyTagam',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // App starts right here at the Auth Screen!
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/feed': (context) => const TestNetworkScreen(),
      },
    );
  }
}

class TestNetworkScreen extends StatefulWidget {
  const TestNetworkScreen({super.key});

  @override
  State<TestNetworkScreen> createState() => _TestNetworkScreenState();
}

class _TestNetworkScreenState extends State<TestNetworkScreen> {
  final OfferRepository _offerRepository = OfferRepository(ApiClient());
  List<dynamic> _offers = [];
  bool _isLoading = false;
  String _errorMessage = '';

  void _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _offerRepository.fetchActiveOffers();
      setState(() {
        _offers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOffers(); // Trigger fetch on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DailyTagam Backend Feed')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : _offers.isEmpty
                  ? const Center(child: Text('No active food offers found.'))
                  : ListView.builder(
                      itemCount: _offers.length,
                      itemBuilder: (context, index) {
                        final offer = _offers[index];
                        return ListTile(
                          title: Text(offer['title'] ?? 'Unknown Item'),
                          subtitle: Text('Price: ${offer['discounted_price']} ₸'),
                          trailing: Text('Qty: ${offer['quantity_available']}'),
                        );
                      },
                    ),
    );
  }
}