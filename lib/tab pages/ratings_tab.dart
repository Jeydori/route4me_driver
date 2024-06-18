import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({Key? key}) : super(key: key);

  @override
  _RatingsTabPageState createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  List<Review> reviews = [];
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;
    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    final uid = currentUser.uid;
    DatabaseReference reviewsRef =
        FirebaseDatabase.instance.ref('Drivers/$uid/reviews');

    reviewsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final allReviews = <Review>[];
      double totalRating = 0.0;

      data.forEach((key, value) {
        try {
          final review = Review.fromMap(Map<String, dynamic>.from(value));
          allReviews.add(review);
          totalRating += review.rating;
        } catch (e) {
          print("Error parsing review data: $e");
        }
      });

      if (allReviews.isNotEmpty) {
        setState(() {
          reviews = allReviews;
          averageRating = totalRating / allReviews.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade600, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review Summary',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${averageRating.toStringAsFixed(1)} ',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800)),
                        Icon(Icons.star,
                            color: Colors.orange.shade800, size: 24),
                      ],
                    ),
                    Divider(color: Colors.orange.shade600),
                    ...List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('${5 - index} ',
                                style: TextStyle(color: Colors.black)),
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (reviews
                                        .where((review) =>
                                            review.rating.round() == 5 - index)
                                        .length) /
                                    (reviews.length == 0 ? 1 : reviews.length),
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange.shade600),
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                                '${reviews.where((review) => review.rating.round() == 5 - index).length}'),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('All Reviews',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              ...reviews.map((review) => ReviewCard(review: review)),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.orange.shade600, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          title: Text(review.comment, style: TextStyle(color: Colors.black87)),
          subtitle: Row(
            children: List.generate(
                5,
                (index) => Icon(
                      index < review.rating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.orange,
                    )),
          ),
        ),
      ),
    );
  }
}

class Review {
  final double rating;
  final String comment;

  Review({required this.rating, required this.comment});

  static Review fromMap(Map<String, dynamic> data) {
    return Review(
      rating: data['rating'].toDouble(),
      comment: data['comment'],
    );
  }
}
