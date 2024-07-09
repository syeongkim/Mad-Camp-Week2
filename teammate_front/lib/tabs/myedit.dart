import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyEdit extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  MyEdit({required this.userInfo});

  @override
  _MyEditPageState createState() => _MyEditPageState();
}

class _MyEditPageState extends State<MyEdit> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _studentIdController;
  late TextEditingController _commentController;
  late TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userInfo['name']);
    _nicknameController =
        TextEditingController(text: widget.userInfo['nickname']);
    _studentIdController =
        TextEditingController(text: widget.userInfo['student_id'].toString());
    _commentController =
        TextEditingController(text: widget.userInfo['user_comment']);
    _capacityController =
        TextEditingController(text: widget.userInfo['user_capacity']);
  }

  Future<void> _updateUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      SharedPreferences prefs2 = await SharedPreferences.getInstance();
      await prefs2.setString('nickname', _nicknameController.text);

      if (userId != null) {
        final Uri uri =
            Uri.parse('http://10.0.2.2:8000/user/edit/$userId').replace();
        final response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text,
            'nickname': _nicknameController.text,
            'student_id': int.parse(_studentIdController.text),
            'user_comment': _commentController.text,
            'user_capacity': _capacityController.text,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, true); // Update successful, return true
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update user info: ${response.statusCode}'),
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update user info: $e'),
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _studentIdController.dispose();
    _commentController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit My Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _updateUserInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Name', _nameController),
            _buildTextField('Nickname', _nicknameController),
            _buildTextField('Student ID', _studentIdController, isNumber: true),
            _buildTextField('Comment', _commentController),
            _buildTextField('Capacity', _capacityController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
