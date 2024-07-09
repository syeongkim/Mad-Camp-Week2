import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammate_front/config.dart';

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
        final response =
            await http.get(Uri.parse('http://$apiurl:8000/alarm/$userId'));
        print(response);
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
              title: Text(alarm['type'] ?? 'No Title'), // null인 경우 기본값 사용
              subtitle: Text(alarm['message'] ?? 'No Content'),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlarmDetailPage(alarm: alarm),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AlarmDetailPage extends StatelessWidget {
  final Map<String, dynamic> alarm;

  AlarmDetailPage({required this.alarm});

  Future<void> _handleAlarmAction(String action) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/alarm/${alarm['id']}/$action'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Alarm $action successfully');
    } else {
      print('Failed to $action alarm: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알람 상세 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alarm['type'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              alarm['message'] ?? 'No Content',
              style: TextStyle(fontSize: 18),
            ),
            // 필요한 경우 추가 정보 표시
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _handleAlarmAction('accept'); // TODO: 팀 멤버에 나 추가하고, 요청 보낸 사람에게 수락 알람 보내기
                    Navigator.of(context).pop(); // 알람 목록으로 돌아가기
                  },
                  child: Text('수락'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _handleAlarmAction('reject'); // TODO: 요청 보낸 사람에게 거절 알람 보내기
                    Navigator.of(context).pop(); // 알람 목록으로 돌아가기
                  },
                  child: Text('거절'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}