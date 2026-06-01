import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'presentation/screens/auth_screen.dart';
import 'core/network/api_client.dart';
import 'data/repositories/offer_repository.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyTagam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
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
  final ApiClient _apiClient = ApiClient();
  late OfferRepository _offerRepository;
  
  List<dynamic> _offers = [];
  bool _isLoading = false;
  final String _userRole = 'business'; // Fixed: Set to final to fix 'prefer_final_fields' warning

  @override
  void initState() {
    super.initState();
    _offerRepository = OfferRepository(_apiClient);
    _loadFeed();
  }

  void _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      final data = await _offerRepository.fetchActiveOffers();
      if (!mounted) return;
      setState(() {
        _offers = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showOfferDetailsSheet(BuildContext context, dynamic offer) {
    double original = (offer['original_price'] as num).toDouble();
    double discounted = (offer['discounted_price'] as num).toDouble();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Text(
                  offer['title'] ?? 'Food Offer', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('${discounted.toStringAsFixed(0)} ₸', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Original Price: ${original.toStringAsFixed(0)} ₸', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Pickup Window: ${offer['pickup_time']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Items Remaining: ${offer['quantity_available']}', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: _userRole == 'business' ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                // Future addition: Trigger a reserve path or edit item method depending on client view state
              },
              child: Text(_userRole == 'business' ? 'Manage This Listing' : 'Reserve Food Item'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAddOfferModal() {
    final titleController = TextEditingController();
    final originalPriceController = TextEditingController();
    final discountedPriceController = TextEditingController();
    final quantityController = TextEditingController();
    final pickupController = TextEditingController(text: "18:00 - 20:00");
    
    File? selectedImage; 
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'List Surplus Leftover Food', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)
                ),
                const SizedBox(height: 16),
                
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setModalState(() {
                        selectedImage = File(image.path);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5), // Fixed warning
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(selectedImage!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.green),
                              SizedBox(height: 8),
                              Text('Upload Food Photo', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: titleController, 
                  decoration: const InputDecoration(labelText: 'Item Title (e.g., Hamburger Box)', border: OutlineInputBorder())
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: originalPriceController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Original Price (₸)', border: OutlineInputBorder())
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: discountedPriceController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Discount Price (₸)', border: OutlineInputBorder())
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController, 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'Quantity Available', border: OutlineInputBorder())
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pickupController, 
                        decoration: const InputDecoration(labelText: 'Pickup Window', border: OutlineInputBorder())
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), 
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white
                  ),
                  onPressed: () async {
  try {
    final token = await _apiClient.storage.read(key: 'access_token');
    
    await _apiClient.dio.post(
      '/business/offers', 
      data: {
        'title': titleController.text,
        'original_price': double.parse(originalPriceController.text),
        'discounted_price': double.parse(discountedPriceController.text),
        'quantity_available': int.parse(quantityController.text),
        'pickup_time': pickupController.text,
        'image_url': selectedImage != null ? selectedImage!.path : 'placeholder_url'
      },
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    
    // --- CHANGE THIS BLOCK TO FIX THE NEW LINTHINT ---
    if (!context.mounted) return; // Explicitly checks this specific bottom-sheet context view tree
    Navigator.pop(context);
    
    _loadFeed(); 
  } catch (e) {
    if (!context.mounted) return; // Guard here as well
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to publish: ${e.toString().contains('403') ? 'Verify Business Account Role' : 'Check Server Connection'}'))
    );
  }
},
                  child: const Text('Publish Discount Listing'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userRole == 'business' ? 'Business Portal: Live Listings' : 'DailyTagam Marketplace'),
        backgroundColor: Colors.green.shade50,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFeed),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () => Navigator.pushReplacementNamed(context, '/')
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.layers_clear, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(_userRole == 'business' ? 'You have no active offers right now.' : 'No surplus food available nearby.'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _offers.length,
                  itemBuilder: (context, index) {
                    final offer = _offers[index];
                    
                    double original = (offer['original_price'] as num).toDouble();
                    double discounted = (offer['discounted_price'] as num).toDouble();
                    double savingsPercent = original > 0 ? (((original - discounted) / original) * 100) : 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell( // --- ADDED FOR TAPPING INTERACTION ---
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Define what happens when a business or user taps a listing card
                          _showOfferDetailsSheet(context, offer);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: const Icon(Icons.fastfood, color: Colors.green, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(offer['title'] ?? 'Surplus Package', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('Pickup: ${offer['pickup_time']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    Text('Remaining Stock: ${offer['quantity_available']}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: Text('-${savingsPercent.toStringAsFixed(0)}%', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${original.toStringAsFixed(0)} ₸', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12)),
                                  Text('${discounted.toStringAsFixed(0)} ₸', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _userRole == 'business'
          ? FloatingActionButton.extended(
              onPressed: _showAddOfferModal,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add Leftover Food'),
            )
          : null,
    );
  }
}