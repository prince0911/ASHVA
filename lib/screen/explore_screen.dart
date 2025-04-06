import 'package:flutter/material.dart';
import 'package:resq_assist/screen/request_details_screen.dart';
import 'package:resq_assist/services/database_helper.dart';

class ExploreScreen extends StatefulWidget {
  final String email;
  const ExploreScreen({super.key, required this.email});


  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> providers = [];
  List<String> selectedCategories = [];
  List<List<double>> selectedPriceRanges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProviders();
  }

  Future<void> loadProviders() async {
    final data = await DatabaseHelper.getAllProviders();
    setState(() {
      providers = data;
      isLoading = false;
    });
  }

  void _showFilterBottomSheet() {
    List<String> tempCategories = List.from(selectedCategories);
    List<List<double>> tempPriceRanges = List.from(selectedPriceRanges);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(26),
            child: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter by Services", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Mechanic', 'Tow-Truck', 'Fuel Transportation'].map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: tempCategories.contains(category),
                        onSelected: (bool selected) {
                          setModalState(() {
                            selected ? tempCategories.add(category) : tempCategories.remove(category);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text("Filter by Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      [300.0, 500.0],
                      [500.0, 1000.0],
                      [1000.0, 2000.0],
                      [2000.0, 3000.0],
                      [3000.0, 5000.0],
                    ].map((range) {
                      final isSelected = tempPriceRanges.any((r) => r[0] == range[0] && r[1] == range[1]);
                      return FilterChip(
                        label: Text('₹${range[0].toInt()} - ₹${range[1].toInt()}'),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setModalState(() {
                            selected
                                ? tempPriceRanges.add(range)
                                : tempPriceRanges.removeWhere((r) => r[0] == range[0] && r[1] == range[1]);
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategories = tempCategories;
                        selectedPriceRanges = tempPriceRanges;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Filters"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProviders = providers.where((provider) {
      final service = (provider['services'] as List).isNotEmpty ? provider['services'][0] : null;
      if (service == null) return false;

      final price = double.tryParse(service['price']?.toString() ?? '0') ?? 0.0;
      final serviceCategories = List<String>.from(service['category'] ?? []);
      final matchesCategory = selectedCategories.isEmpty ||
          serviceCategories.any((cat) => selectedCategories.contains(cat));
      final matchesPrice = selectedPriceRanges.isEmpty ||
          selectedPriceRanges.any((range) => price >= range[0] && price <= range[1]);
      return matchesCategory && matchesPrice;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ASHVA',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.person_outline, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: 'Search Service Center',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onPressed: _showFilterBottomSheet,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                itemCount: filteredProviders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final provider = filteredProviders[index];
                  final service = provider['services'][0];
                  print(provider);
                  return ServiceCard(
                    name: provider['business_name'] ?? 'Unknown',
                    minPrice: double.tryParse(service['minprice']?.toString() ?? '0') ?? 0.0,
                    maxPrice: double.tryParse(service['maxprice']?.toString() ?? '0') ?? 0.0,
                    rating: double.tryParse(service['rating']?.toString() ?? '0') ?? 0.0,
                    distance: service['distance'] ?? 'N/A',
                    eta: service['eta'] ?? 'N/A',
                    services: List<String>.from(service['category'] ?? []),
                    isOnline: service['available'] ?? false,
                    email: widget.email,
                    pEmail: provider['email'],
                    serviceName: (service['category'] as List).isNotEmpty
                        ? service['category'][0]
                        : 'Service',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String name;
  final double minPrice;
  final double maxPrice;
  final double rating;
  final String distance;
  final String eta;
  final List<String> services;
  final bool isOnline;
  final String email; // 👈 Add this
  final String pEmail; // 👈 Add this
  final String serviceName;

  const ServiceCard({
    super.key,
    required this.name,
    required this.minPrice,
    required this.maxPrice,
    required this.rating,
    required this.distance,
    required this.eta,
    required this.services,
    this.isOnline = false,
    required this.email,
    required this.pEmail,
    required this.serviceName,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.home_repair_service, color: Colors.black54),
                    ),
                    if (isOnline)
                      const CircleAvatar(
                        radius: 7,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                              child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(rating.toString(), style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '₹${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 4),
                Text(distance),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 4),
                Text("ETA: $eta"),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: services.map((service) {
                return Chip(label: Text(service));
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.purple),
                  ),
                  icon: const Icon(Icons.call, color: Colors.purple),
                  label: const Text('Contact', style: TextStyle(color: Colors.purple)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RequestDetailsScreen(email: email,serviceName: serviceName,minPrice: minPrice.toInt(),maxPrice: maxPrice.toInt(),providerEmail: pEmail,),));

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Request', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
