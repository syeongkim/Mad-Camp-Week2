import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int user_id;

  ProfilePage({required this.user_id});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(widget.user_id);
  }

  Future<void> _fetchUserData(user_id) async {
    user_id = user_id.toString();
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/user/view/$user_id'));

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('An error occurred: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text('Failed to load user data'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Name: ${userData!["name"]}',
                          style: TextStyle(fontSize: 20)),
                      Text('User Nickname: ${userData!["nickname"]}',
                          style: TextStyle(fontSize: 20)),
                      Text('User Student Id: ${userData!["student_id"]}',
                          style: TextStyle(fontSize: 20)),
                      Text('User Commnet: ${userData!["user_comment"]}',
                          style: TextStyle(fontSize: 20)),
                      Text('User Capacity: ${userData!["user_capacity"]}',
                          style: TextStyle(fontSize: 20))
                    ],
                  ),
                ),
    );
  }
}
