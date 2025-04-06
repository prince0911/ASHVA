import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:resq_assist/model/user_model.dart'; // Import your model

class DatabaseHelper {
  static late Db _db;
  static late DbCollection _trackingCollection;
  static late DbCollection _reviewsCollection;
  static late DbCollection _usersCollection;
  static late DbCollection _providerCollection;
  static late DbCollection _bookServiceCollection;
  static late DbCollection _paymentCollection;
// ✅ Add users collection

  static const String baseUrl =
      "https://8446-2409-40c1-110d-db-643c-a30-15cd-2f71.ngrok-free.app";

  /// ✅ Connects to MongoDB Atlas
  static Future<void> connect() async {
    try {
      // _db = await Db.create("mongodb+srv://rapidtow04:M817PAYgfkv7Ae4q@cluster0.eivh2.mongodb.net/RapidTow?retryWrites=true&w=majority&tls=true");
      _db = await Db.create("mongodb+srv://rapidtow04:M817PAYgfkv7Ae4q@cluster0.eivh2.mongodb.net/RapidTow?retryWrites=true&w=majority&tls=true");
      await _db.open();
      _trackingCollection = _db.collection("live_tracking");
      _reviewsCollection = _db.collection("reviews");
      _usersCollection = _db.collection("usersDetails");
      _providerCollection = _db.collection("serviceProvider");
      _bookServiceCollection = _db.collection("bookService");
      _paymentCollection = _db.collection("paymentService");
// ✅ Initialize users collection
      print("✅ Connected to MongoDB Atlas!");
    } catch (e) {
      print("❌ MongoDB Connection Error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getAllProviders() async {
    try {
      final providers = await _providerCollection.find().toList();
      return providers.map((doc) => Map<String, dynamic>.from(doc)).toList();
    } catch (e) {
      print("❌ Error fetching all providers: $e");
      return [];
    }
  }


  static Future<List<Map<String, dynamic>>> getProvidersByCategory(String category) async {
    try {
      final providers = await _providerCollection
          .find(where.eq("services.category", category))
          .toList();

      return providers.map((doc) => Map<String, dynamic>.from(doc)).toList();
    } catch (e) {
      print("❌ Error fetching providers: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getBookingsByUserId(String email) async {
    try {


      final bookings = await _bookServiceCollection
          .find(where.eq('email', email))
          .toList();

      return bookings.map((doc) => Map<String, dynamic>.from(doc)).toList();
    } catch (e) {
      print("❌ Error fetching bookings: $e");
      return [];
    }
  }

  static Future<String> updateByEmail(String email,int tripPoints) async {
    try {
     // Replace 'users' with your actual collection name

      var result = await _usersCollection.update(
          where.eq('email', email), // Match document where email matches
          modify
          // Set new fName
              .set('travelPoints', tripPoints) // Set new lName
        // .set('address', address)
        // .set('dateOfBirth', dateOfBirth)
        // Set new phone number
        // Set new phone number
      );

      // Check if the update modified any documents
      if (result['nModified'] != null && result['nModified'] > 0) {
        return "Data Updated";
      } else {
        return "Update Failed or No Document Found with Email: $email";
      }
    } catch (e) {
      print('Error updating data: $e');
      return e.toString();
    }
  }

  static Future<bool> paymentUser(ObjectId pid, ObjectId uid ,String email,String fullName,String serviceName,String vehicleType,String vehicleModel,String numberPlate, String paymentPrice,String paymentMode,String paymentDate) async {
    try {


      var result = await _paymentCollection.insertOne({
        'id': pid,
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'serviceName': serviceName,
        'vehicleType': vehicleType,
        'vehicleModel': vehicleModel,
        'numberPlate': numberPlate,
        'paymentPrice': paymentPrice,
        'paymentMode': paymentMode,
        'paymentDate': paymentDate,
      });

      // Log success or failure
      if (result.isSuccess) {
        print('User Payment successfully.');
      } else {
        print('Failed to Payment user.');
      }

      return result.isSuccess;
    } catch (e) {
      print('Error paying from user: $e');
      return false;
    }
  }

  static Future<bool> bookUser( ObjectId uid ,String fullName,String email,String pEmail, String contactNo,String address, String serviceName,String vehicleType,String vehicleModel,String numberPlate, String bookPrice,String bookDate,String bookTime,String status) async {
    try {

      var result = await _bookServiceCollection.insertOne({

        'uid': uid,
        'fullName': fullName,
        'email': email,
        'providerEmail': pEmail,
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
      });

      // Log success or failure
      if (result.isSuccess) {
        print('User booked successfully.');
      } else {
        print('Failed to book user.');
      }

      return result.isSuccess;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getDataOfUserByEmail(String email) async {
    try {

      // Find the document where the email matches
      var userDocument = await _usersCollection.findOne({"email": email});

      // If a document is found, return it
      if (userDocument != null) {
        return userDocument;
      } else {
        print("No user found with the email: $email");
        return null;
      }
    } catch (e) {
      print('Error retrieving data: $e');
      return null;
    }
  }

  static Future<bool> addUser(UserModel user) async {
    final url = Uri.parse("https://8586-117-239-204-225.ngrok-free.app/api/users/add");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("❌ Failed to add user: ${response.body}");
      return false;
    }
  }

  // ✅ Insert a new user into MongoDB
  // static Future<bool> addUser(UserModel user) async {
  //   try {
  //     var result = await _usersCollection.insertOne(user.toJson());
  //     return result.isSuccess;
  //   } catch (e) {
  //     print("❌ Error inserting user: $e");
  //     return false;
  //   }
  // }


  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final user = await _usersCollection.findOne({'email': email});

      if (user != null) {
        final storedHash = user['password'];
        final inputHash = hashPassword(password); // Hash input the same way
        print(inputHash);
        if (storedHash == inputHash) {
          return user;
        }
      }

      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }



  // ✅ Fetch a single agent's live location by `agentId`
  static Future<Map<String, dynamic>?> fetchAgentLocation(String agentId) async {
    try {
      return await _trackingCollection.findOne(where.eq('agent_id', agentId));
    } catch (e) {
      print("❌ Error fetching agent location: $e");
      return null;
    }
  }

  // ✅ Fetch all agents' live locations
  static Future<List<Map<String, dynamic>>> fetchAllAgents() async {
    try {
      final agents = await _trackingCollection.find().toList();
      return agents.map((doc) => Map<String, dynamic>.from(doc)).toList();
    } catch (e) {
      print("❌ Error fetching all agents: $e");
      return [];
    }
  }

  static Future<bool> addReview(String garageName, double rating, String comment) async {
    try {
      var result = await _reviewsCollection.insertOne({
        "garageName": garageName,
        "rating": rating,
        "comment": comment,
        "timestamp": DateTime.now().toIso8601String()
      });

      return result.isSuccess;
    } catch (e) {
      print("❌ Error adding review: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getReviews(String garageName) async {
    try {
      final reviews = await _reviewsCollection.find({"garageName": garageName}).toList();
      return reviews.map((doc) => Map<String, dynamic>.from(doc)).toList();
    } catch (e) {
      print("❌ Error fetching reviews: $e");
      return [];
    }
  }

  static Future<bool> updateAgentLocation(String agentId, double lat, double lng) async {
    try {
      await _trackingCollection.update(
        where.eq("agent_id", agentId),
        modify.set("latitude", lat).set("longitude", lng),
        upsert: true,
      );
      return true;
    } catch (e) {
      print("❌ Error updating agent location: $e");
      return false;
    }
  }

  static Future<bool> deleteAgentLocation(String agentId) async {
    try {
      var result = await _trackingCollection.remove(where.eq("agent_id", agentId));
      if (result["n"] > 0) {
        print("✅ Agent location deleted successfully!");
        return true;
      } else {
        print("⚠️ No matching agent found.");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting agent location: $e");
      return false;
    }
  }

  static Future<void> closeConnection() async {
    try {
      await _db.close();
      print("✅ MongoDB Connection Closed.");
    } catch (e) {
      print("❌ Error closing connection: $e");
    }
  }
}
