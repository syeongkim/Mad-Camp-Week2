import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teammate_front/config.dart';

class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<Map<String, dynamic>> allPosts;
  final int userId;
  final bool isMypost;

  PostDetailsPage({required this.post, required this.allPosts, required this.userId, required this.isMypost});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  int? userId;
  String? nickname;

  @override
  void initState() {
    super.initState();
    _fetchAndSetNickname();
  }

  // Future<int?> _getUserId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   userId = prefs.getInt('userId');
  //   print(widget.post['leader_id']);
  //   print(userId);
  //   return userId;
  // }

  Future<void> _fetchAndSetNickname() async {
    final leaderId = widget.post['leader_id'];
    if (leaderId != null) {
      final userDetails = await _fetchUserDetails(leaderId);
      if (userDetails != null) {
        setState(() {
          nickname = userDetails['nickname'];
        });
      }
    }
  }

  Future<void> _deletePost(int postId, int leaderId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/teamposts/post/$postId/$leaderId'),
      );

      if (response.statusCode == 200) {
        print('Post deleted successfully.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('삭제되었습니다.'),
        ));
        Navigator.of(context).pop(true); // 다이얼로그 닫기 및 값 반환
      } else {
        print('Failed to delete post: ${response.statusCode}');
        Navigator.of(context).pop(false); // 삭제 실패 시 값 반환
      }
    } catch (e) {
      print('Error deleting post: $e');
      Navigator.of(context).pop(false); // 삭제 실패 시 값 반환
    }
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(int leaderId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/user/update/$leaderId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load user details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading user details: $e');
      return null;
    }
  }

  void _showUserDetailsDialog(BuildContext context, int leaderId) async {
    Map<String, dynamic>? userDetails = await _fetchUserDetails(leaderId);

    if (userDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('사용자 정보를 불러오는데 실패했습니다.'),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nickname: ${userDetails['nickname'] ?? 'N/A'}'),
                Text('User capacity: ${userDetails['user_capacity'] ?? 'N/A'}'),
                Text('User comment: ${userDetails['user_comment'] ?? 'N/A'}'),
                // 필요한 다른 사용자 정보 추가
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기', style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendAlarm(String alarmType, Map<String, dynamic> post) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nickname = prefs.getString('nickname');

    try {
      //String message = 'nickname님으로부터 함께하기 요청을 받았습니다';
      // switch(alarmType) {
      //   case 'request':
      //     message = 'nickname님으로부터 함께하기 요청을 받았습니다';
      //   case 'answer':
      //     message = '';
      //   case 'reminder':
      //     message = '';
      // }
      //print(message);
      var alarmData = {
        'receiver_id': post['leader_id'],
        'sender_id': prefs.getInt('userId'),
        'post_id': post['post_id'],
        'type': alarmType,
        'message': 'nickname님으로부터 함께하기 요청을 받았습니다'
        // 'message': "땡땡님으로부터 요청이 들어왔습니다!",
        // 'read': post[],
        // 'created_at': post[]
      };

      final response = await http.post(
        Uri.parse('http://$apiurl:8000/alarm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alarmData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to send alarm: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error sending alarm: $e');
      return null;
    }
  }

  Future<void> _saveRequest(int postId, int leaderId, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    var requestData = {
      'post_id': postId,
      'leader_id': leaderId,
      'sender_id': userId,
      'comment': comment,
    };

    final response = await http.post(
      Uri.parse('http://$apiurl:8000/teamposts/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to save request: ${response.statusCode}');
    }
  }

  void _showDeleteConfirmationDialog(int postId, int leaderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('정말 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('삭제'),
              onPressed: () async {
                Navigator.of(context).pop(); // 삭제 확인 다이얼로그 닫기
                await _deletePost(postId, leaderId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(249, 214, 219, 1),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      _showUserDetailsDialog(context, widget.post['leader_id']),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Color.fromRGBO(236, 138, 177, 1),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      nickname ?? 'Leader ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(
                          widget.post['post_date'] ??
                              DateTime.now().toString())),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              widget.post['post_title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Course ID: ${widget.post['course_id'] ?? 'N/A'}'),
            Text('Leader ID: ${widget.post['leader_id'] ?? 'N/A'}'),
            Text('Content: ${widget.post['post_content'] ?? 'N/A'}'),
            Text('Capacity: ${widget.post['member_limit'] ?? 'N/A'}'),
            Text(
                'Due Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(widget.post['due_date'] ?? DateTime.now().toString()))}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('닫기', style: TextStyle(color: Colors.black),),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        if (widget.isMypost)
          ElevatedButton(
            child: Text('삭제', style: TextStyle(color: Colors.black),),
            onPressed: () => _showDeleteConfirmationDialog(
                widget.post['post_id'], widget.post['leader_id']),
          )
        else
          ElevatedButton(
            child: Text('요청', style: TextStyle(color: Colors.black),),
            onPressed: () {
              _saveRequest(
                  widget.post['post_id'], widget.post['leader_id'], '함께하기 요청');
              _sendAlarm('request', widget.post);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('요청되었습니다!'),
              ));
            },
          ),
      ],
    );
  }
}

Future<bool> showPostDetailsDialog(BuildContext context,
    Map<String, dynamic> post, List<Map<String, dynamic>> allPosts) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId')!;
      bool isMypost = post['leader_id'] == userId;
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return PostDetailsPage(post: post, allPosts: allPosts, userId: userId, isMypost: isMypost);
        },
      ) ??
      false;
}
