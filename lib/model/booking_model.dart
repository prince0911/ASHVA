import 'package:mongo_dart/mongo_dart.dart';

class Booking {
  final ObjectId? id; // MongoDB _id (optional)
  final ObjectId uid; // Required - user reference
  final String fullName;
  final String email;
  final String providerEmail;
  final String contactNo;
  final String address;
  final String serviceName;
  final String vehicleType;
  final String vehicleModel;
  final String numberPlate;
  final String bookPrice;
  final String bookDate;
  final String bookTime;
  final String status;

  Booking({
    this.id,
    required this.uid,
    required this.fullName,
    required this.email,
    required this.providerEmail,
    required this.contactNo,
    required this.address,
    required this.serviceName,
    required this.vehicleType,
    required this.vehicleModel,
    required this.numberPlate,
    required this.bookPrice,
    required this.bookDate,
    required this.bookTime,
    required this.status,
  });

  /// Convert MongoDB document to Booking object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      uid: json['uid'],
      fullName: json['fullName'],
      email: json['email'],
      providerEmail: json['providerEmail'],
      contactNo: json['contactNo'],
      address: json['address'],
      serviceName: json['serviceName'],
      vehicleType: json['vehicleType'],
      vehicleModel: json['vehicleModel'],
      numberPlate: json['numberPlate'],
      bookPrice: json['bookPrice'],
      bookDate: json['bookDate'],
      bookTime: json['bookTime'],
      status: json['status'],
    );
  }

  /// Convert Booking object to MongoDB-compatible map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'providerEmail': providerEmail,
      'contactNo': contactNo,
      'address': address,
      'serviceName': serviceName,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'numberPlate': numberPlate,
      'bookPrice': bookPrice,
      'bookDate': bookDate,
      'bookTime': bookTime,
      'status': status,
    };
  }
}
