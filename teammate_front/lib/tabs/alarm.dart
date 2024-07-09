import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlarmList extends StatefulWidget {
  @override
  _AlarmListState createState() => _AlarmListState();
}

class _AlarmListState extends State<AlarmList> {
  List<Map<String, dynamic>> alarms = [];

  @override
  void initState() {
    super.initState();
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId != null) {
        final response = await http.get(Uri.parse('http://10.0.2.2:8000/alarm/$userId'));

        if (response.statusCode == 200) {
          print("alarm successfully received");
          setState(() {
            alarms = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          });
        } else {
          print('Failed to load alarms: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error loading alarms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 목록'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: alarms.length,
          itemBuilder: (context, index) {
            var alarm = alarms[index];
            return ListTile(
              //tileColor: Colors.white,
              title: Text(alarm['type'] ?? 'No Title'),  // null인 경우 기본값 사용
              subtitle: Text(alarm['message'] ?? 'No Content'),
              isThreeLine: true,
            );
          },
        ),
      ),
    );
  }
}
