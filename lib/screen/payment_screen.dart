import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:resq_assist/services/database_helper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class PaymentScreen extends StatefulWidget {
  final M.ObjectId uid;
  final String email;
  final String serviceName;
  final String bookTime;
  final String bookDate;
  final String fullName;
  final String address;
  final String vehicleModel;
  final String numberPlate;
  final String vehicleType;
  final String contactNo;

  final String paymentDate;

  const PaymentScreen({
    required M.ObjectId this.uid,
    required String this.email,
    required String this.serviceName,
    required String this.bookTime,
    required String this.bookDate,
    required String this.fullName,
    required String this.address,
    required String this.vehicleModel,
    required String this.numberPlate,
    required String this.vehicleType,
    required String this.contactNo,

    required String this.paymentDate,
    super.key,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Variable to track the selected payment method (1: Card, 2: UPI, 3: Cash)
  int _selectedPaymentMethod = 0;
  String _selectedMode = '';
  late Razorpay _razorPay;
  var tripPoints;
  int tripPointsForUpdate = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchUserData(widget.email).then((data) {
      setState(() {
        tripPoints = (data["travelPoints"] ?? 0).toInt();
      });
      tripPointsForUpdate = int.parse(tripPoints.toString());
    });
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  // Function to change selected payment method
  void _selectPaymentMethod(int method,String mode) {
    setState(() {
      _selectedPaymentMethod = method;
      _selectedMode = mode;
    });
  }
  Future<Map<String, dynamic>> fetchUserData(String email) async {
    var data = await DatabaseHelper.getDataOfUserByEmail(email) ?? {};
    return {
      "travelPoints": (data["travelPoints"] ?? 0).toInt(),
    };
  }

  int getRandomMultipleOfTen() {
    Random random = Random();
    int min = 500;
    int max = 1000;

    // Generate a random multiple of 10 in range [500, 1000]
    int randomValue = (random.nextInt((max - min) ~/ 10 + 1) * 10) + min;

    return randomValue;
  }


  void _handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {
    int points = getRandomMultipleOfTen();
    print(widget.contactNo);

    await DatabaseHelper.updateByEmail(widget.email, tripPointsForUpdate+points);
    // _saveInvoice("Online Payment", widget.package.pricing.budget, paymentId: response.paymentId!);
    _showLottieDialog(context, points);

    print('lotti done!');
    showSnackBar(context," Payement Succesful " , Icons.done_all_rounded ,Colors.green);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showSnackBar(context, "Payment Failed: ${response.message}", Icons.error_outline, Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //       content: Text("External Wallet Selected: ${response.walletName}")),
    // );
    showSnackBar(context, "External Wallet Selected: ${response.walletName}", Icons.account_balance_wallet_outlined, Colors.green);
  }
  Future<void> _showLottieDialog(BuildContext context ,int points) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing until animation completes
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                width: 300,
                child: Lottie.asset(
                  "assets/images/animation.json",
                  repeat: true, // Run once
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "You Got ", // Normal text
                    style: TextStyle(color: Colors.green, fontSize: 17, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        text: "$points Points", // Bold text
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " in your wallet!", // Normal text
                      ),
                    ],
                  ),
                ),

              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  showSnackBar(context, "Congratulations! Your tour is successfully booked.", Icons.done_all_rounded, Colors.green);
                },
                child: Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 86, 142, 177),
                        Color.fromARGB(255, 131, 192, 228),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text("Done",
                      style: TextStyle(color: Colors.white, fontSize: 16),textAlign: TextAlign.center,),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void startPayment(int amount) {
    var options = {
      'key': 'rzp_test_dZElgg9nNyp4Vw',
      'amount': (amount * 100).toInt(),
      'name': 'CodeResQ',
      'description': 'Payment For Booking',
      'prefill': {'contact': widget.contactNo, 'email': widget.email},
    };
    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 35, 24, 29),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section (Back button and title)
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 52),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Payment ',
                      style: GoogleFonts.getFont(
                        'Open Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: 1.4,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),
                ),

                // Payment Details Section
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x33000000)),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFFFFFF),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        offset: Offset(0, 7),
                        blurRadius: 5.5,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(23.5, 20.5, 23.5, 23.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Summary Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.serviceName,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${widget.bookTime}  ${widget.bookDate}",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.fullName,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.address,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.serviceName.compareTo('Rescue Me') != 0) ...[
                          SizedBox(height: 5),
                          Text(
                            widget.vehicleModel,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            widget.numberPlate,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 20),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Vehicle - ${widget.vehicleType}",
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                "550/-",
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),

                          SizedBox(height: 10),
                        ],
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Amount Payable",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "550/-",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Payment Method Section
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x33000000)),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFFFFFF),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        offset: Offset(0, 7),
                        blurRadius: 5.5,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(23.5, 20.5, 23.5, 23.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 19),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Payment Methods',
                              style: GoogleFonts.getFont(
                                'Open Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: const Color(0xFF000000),
                              ),
                            ),
                          ),
                        ),

                        // Credit / Debit Card Option (Selectable Container)
                        GestureDetector(
                          onTap: () => _selectPaymentMethod(1,"online"),
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethod == 1
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.white,
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Razor Pay ( Online )',
                                  style: GoogleFonts.getFont(
                                    'Open Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                                const Icon(Icons.arrow_right_alt),
                              ],
                            ),
                          ),
                        ),

                        // UPI Option (Selectable Container)


                        // Cash On Delivery Option (Selectable Container)
                        GestureDetector(
                          onTap: () => _selectPaymentMethod(2,"COD"),
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethod == 2
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.white,
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment By Cash',
                                  style: GoogleFonts.getFont(
                                    'Open Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                                const Icon(Icons.arrow_right_alt),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.serviceName.compareTo('Rescue Me') == 0) ...[
                  SizedBox(
                    height: 150,
                  ),
                ],
                // Pay Button
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          // Check if a payment method has been selected
                          if (_selectedPaymentMethod != 0) {
                            // Proceed to payment logic
                            // You can handle different payment method logic here
                            switch (_selectedPaymentMethod) {
                              case 1:
                              // Handle Credit/Debit Card payment
                               startPayment(550);
                                break;
                              case 2:
                              // Handle UPI payment

                                break;

                            }

                            var _id = M.ObjectId();
                            print(_id);

                            bool success = await DatabaseHelper.paymentUser(
                              _id,
                              widget.uid,
                              widget.email,
                              widget.fullName,
                              widget.serviceName,
                              widget.vehicleType,
                              widget.vehicleModel,
                              widget.numberPlate,
                              "550",
                              _selectedMode,
                              widget.paymentDate,
                            );

                          } else {
                            // If no payment method is selected, show a message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a payment method'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF101010),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5.6, 9, 0, 13),
                            child: Center(
                              child: Text(
                                'Pay',
                                style: GoogleFonts.getFont(
                                  'Open Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void showSnackBar(BuildContext context , String message, IconData icon ,Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: Colors.white), // ⚠ Icon
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        // Transparent to apply gradient
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        margin: EdgeInsets.only(
            bottom: 50, left: 10, right: 10),
        elevation: 0,
      ),
    );
  }
}
