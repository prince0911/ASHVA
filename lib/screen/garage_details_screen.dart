import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:resq_assist/services/database_helper.dart';
class GarageDetailScreen extends StatefulWidget {
  final String garageName;
  const GarageDetailScreen({required this.garageName});

  @override
  _GarageDetailScreenState createState() => _GarageDetailScreenState();
}

class _GarageDetailScreenState extends State<GarageDetailScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    List<Map<String, dynamic>> fetchedReviews = await DatabaseHelper.getReviews(widget.garageName);
    setState(() {
      _reviews = fetchedReviews;
    });
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Rate ${widget.garageName}", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Leave a review...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.addReview(widget.garageName, _rating, _commentController.text);
                _fetchReviews();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review submitted!")));
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.garageName)),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showRateDialog(context),
            child: Text("Rate Us"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _reviews.isEmpty
                ? Center(child: Text("No reviews yet"))
                : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  title: Text("⭐ ${review['rating']} - ${review['comment']}"),
                  subtitle: Text(review['timestamp']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}