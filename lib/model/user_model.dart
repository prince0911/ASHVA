class UserModel {
  final String username;
  final String fullName;
  final String email;
  final String contactNo;
  final String emergencyContact;
  final String homeAddress;
  final String gender;
  final String password;
  final String vehicleType;
  final String vehicleModel;
  final String numberPlate;
  final int travelPoints;

  UserModel({
    required this.username,
    required this.fullName,
    required this.email,
    required this.contactNo,
    required this.emergencyContact,
    required this.homeAddress,
    required this.gender,
    required this.password,
    required this.vehicleType,
    required this.vehicleModel,
    required this.numberPlate,
    required this.travelPoints,
  });

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      contactNo: json['contactNo'],
      emergencyContact: json['emergencyContact'],
      homeAddress: json['homeAddress'],
      gender: json['gender'],
      password: json['password'],
      vehicleType: json['vehicleType'],
      vehicleModel: json['vehicleModel'],
      numberPlate: json['numberPlate'],
      travelPoints: json['travelPoints'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'email': email,
      'contactNo': contactNo,
      'emergencyContact': emergencyContact,
      'homeAddress': homeAddress,
      'gender': gender,
      'password': password,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'numberPlate': numberPlate,
      'travelPoints': travelPoints,
    };
  }
}
