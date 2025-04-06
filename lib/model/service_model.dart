class MechanicServiceProvider {
  final String id;
  final String providerName;
  final String email;
  final String phone;
  final String businessName;
  final String serviceArea;
  final List<Service> services;

  MechanicServiceProvider({
    required this.id,
    required this.providerName,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.serviceArea,
    required this.services,
  });

  factory MechanicServiceProvider.fromJson(Map<String, dynamic> json) {
    return MechanicServiceProvider(
      id: json['_id']['\$oid'],
      providerName: json['provider_name'],
      email: json['email'],
      phone: json['phone'],
      businessName: json['business_name'],
      serviceArea: json['service_area'],
      services: List<Service>.from(json['services'].map((s) => Service.fromJson(s))),
    );
  }
}

class Service {
  final String name;
  final String description;
  final int minPrice;
  final int maxPrice;
  final String priceType;
  final List<String> category;
  final String distance;
  final String eta;
  final double rating;
  final bool available;

  Service({
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.priceType,
    required this.category,
    required this.distance,
    required this.eta,
    required this.rating,
    required this.available,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'],
      description: json['description'],
      minPrice: json['minPrice']['\$numberInt'] != null
          ? int.parse(json['price']['\$numberInt'])
          : 0,
      maxPrice: json['price']['\$numberInt'] != null
          ? int.parse(json['price']['\$numberInt'])
          : 0,
      priceType: json['price_type'],
      category: List<String>.from(json['category']),
      distance: json['distance'],
      eta: json['eta'],
      rating: json['rating']['\$numberDouble'] != null
          ? double.parse(json['rating']['\$numberDouble'])
          : 0.0,
      available: json['available'],
    );
  }
}
