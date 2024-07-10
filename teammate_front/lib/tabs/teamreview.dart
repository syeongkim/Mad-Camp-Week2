import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:teammate_front/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeamReviewPage extends StatelessWidget {
  final List<int> memberIds;

  TeamReviewPage({required this.memberIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Review'),
      ),
      body: ListView.builder(
        itemCount: memberIds.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Member ID: ${memberIds[index]}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberReviewPage(memberId: memberIds[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MemberReviewPage extends StatefulWidget {
  final int memberId;

  MemberReviewPage({required this.memberId});

  @override
  _MemberReviewPageState createState() => _MemberReviewPageState();
}

class _MemberReviewPageState extends State<MemberReviewPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitReview(double score, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? reviewerId = prefs.getInt('userId');

    var postData = {
          'reviewer_id': reviewerId,
          'reviewee_id': widget.memberId,
          'score': score,
          'comment': comment,
        };

    final url = 'http://$apiurl:8000/reviews'; // 여기에 실제 API 엔드포인트를 입력하세요.
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(postData),
    );

    if (response.statusCode == 200) {
      // 리뷰 제출이 성공적으로 처리된 경우
      print('Review submitted successfully');
    } else {
      // 리뷰 제출에 실패한 경우
      print('Failed to submit review');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review for Member ${widget.memberId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this member:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Write a comment:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your comment here',
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Submit the review
                  await _submitReview(_rating, _commentController.text);
                  Navigator.pop(context); // Go back to the previous screen
                },
                child: Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: TeamReviewPage(memberIds: [234, 345, 3610024297]),
  ));
}
