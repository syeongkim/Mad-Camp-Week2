import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'myedit.dart';
import 'package:teammate_front/config.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, dynamic> userInfo = {
    'user_id': 0,
    'name': "",
    'nickname': "",
    'student_id': 0,
    'user_comment': "",
    'user_capacity': "",
    'created_at': ""
  };

  List<Map<String, dynamic>> userReviews = [];

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchUserReviews();
  }

  Future<void> _fetchUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId != null) {
        final Uri uri =
            Uri.parse('http://$apiurl:8000/user/update/$userId').replace();
        http.Response response = await http.get(uri);
        setState(() {
          userInfo = json.decode(response.body) as Map<String, dynamic>;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('사용자 정보 가져오기 실패: $e'),
      ));
    }
  }

  Future<void> _fetchUserReviews() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId != null) {
        final Uri uri =
            Uri.parse('http://$apiurl:8000/reviews/$userId').replace();
        http.Response response = await http.get(uri);
        final responseBody = json.decode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            userReviews = (responseBody as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('리뷰 가져오기 실패: $e'),
      ));
    }
  }

  Future<void> _userEdit() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEdit(userInfo: userInfo),
      ),
    );

    if (updated == true) {
      _fetchUserInfo();
      _fetchUserReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('나의 프로필', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _userEdit,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUserInfo();
          await _fetchUserReviews();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildInfo('이름', userInfo["name"]),
              _buildInfo('Nickname', userInfo['nickname']),
              _buildInfo('Comment', userInfo['user_comment']),
              _buildInfo('Student ID', userInfo['student_id'].toString()),
              _buildInfo('Capacity', userInfo['user_capacity']),
              _buildInfo('Created At', userInfo['created_at']),
              SizedBox(height: 16.0),
              Text('Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Choson')),
              _buildReviewsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label),
        subtitle: Text(info),
      ),
    );
  }

  Widget _buildReviewsList() {
    if (userReviews.isEmpty) {
      return Center(child: Text('No reviews found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: userReviews.length,
      itemBuilder: (context, index) {
        final review = userReviews[index];
        final score =
            review['score'] != null ? review['score'].toDouble() : 0.0;
        return ListTile(
          title: RatingBarIndicator(
            rating: score,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 20.0,
            direction: Axis.horizontal,
          ),
          subtitle: Text(review['content'] ?? 'No content'),
        );
      },
    );
  }
}
