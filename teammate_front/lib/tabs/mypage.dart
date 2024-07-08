import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    'courses_taken_id': [],
    'skill_id': [],
    'user_comment': "",
    'created_at': ""
  };

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId != null) {
        final Uri uri = Uri.parse('http://10.0.2.2:8000/user/return').replace(
          queryParameters: {
            'user_id': userId.toString(),
          },
        );
        http.Response response = await http.get(uri);
        setState(() {
          userInfo = json.decode(response.body) as Map<String, dynamic>;
        });
      }
    } catch (e) {
      // 요청 실패 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('사용자 정보 가져오기 실패: $e'),
      ));
    }
  }

  void _userEdit() {
    // 편집 버튼 클릭 시 수행할 동작 추가
    print('Edit button clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _userEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfo('Name', userInfo['name']),
            _buildInfo('Nickname', userInfo['nickname']),
            _buildInfo('Comment', userInfo['user_comment']),
            _buildInfo('Student ID', userInfo['student_id'].toString()),
            _buildInfo('Courses Taken',
                (userInfo['courses_taken_id'] as List).join(', ')),
            _buildInfo('Skills', (userInfo['skill_id'] as List).join(', ')),
            _buildInfo('Created At', userInfo['created_at']),
          ],
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
}
