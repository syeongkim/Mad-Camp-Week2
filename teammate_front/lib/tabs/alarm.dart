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

  Future<void> readAlarm(int alarmId) async {
    try {
      final response = await http.put(
        Uri.parse('http://$apiurl:8000/alarm/$alarmId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'read': true}),
      );

      if (response.statusCode == 200) {
        print('Alarm read successfully');
      } else {
        print('Failed to read alarm: ${response.statusCode}');
      }
    } catch (e) {
      print('Error reading alarm: $e');
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
                readAlarm(alarm['alarm_id']); // 알람 읽음 처리
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

  Future<void> _addToTeam(int postId, int senderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    var teamData = {'team_id': postId, 'member_id': senderId};
    if (userId != null) {
      final response = await http.post(
        Uri.parse('http://$apiurl:8000/teamposts/team/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(teamData),
      );

      if (response.statusCode == 200) {
        print('Team successfully added');
      } else {
        print('Failed to add team: ${response.statusCode}');
      }
    }
  }

  Future<bool> _isTeamFull(int teamId) async {
    final response = await http.post(
      Uri.parse('http://$apiurl:8000/teamposts/team/count/$teamId'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['is_full'] == true;
    } else {
      print('Failed to check team status: ${response.statusCode}');
      return false;
    }
  }

  Future<void> _handleAlarmAction(
      String action, int receiver, int postId, BuildContext context) async {
    if (action == 'accept') {
      bool isFull = await _isTeamFull(postId);
      if (isFull) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('팀의 인원이 이미 다 찼습니다.'),
        ));
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');
      var alarmData = {
        'receiver_id': receiver,
        'sender_id': userId,
        'post_id': postId,
        'type': 'accept',
        'message': 'nickname님이 함께하기 요청을 수락했습니다'
      };
      if (userId != null) {
        final response = await http.post(
          Uri.parse('http://$apiurl:8000/alarm'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(alarmData),
        );

        if (response.statusCode == 200) {
          print('addtoteam 정상작동하나?');
          await _addToTeam(postId, receiver);
          print('Alarm $action successfully');
        } else {
          print('Failed to $action alarm: ${response.statusCode}');
        }
      }
    } else if (action == 'reject') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');
      var alarmData = {
        'receiver_id': receiver,
        'sender_id': userId,
        'post_id': postId,
        'type': 'reject',
        'message': 'nickname님이 함께하기 요청을 거절했습니다'
      };
      if (userId != null) {
        final response = await http.post(
          Uri.parse('http://$apiurl:8000/alarm'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(alarmData),
        );

        if (response.statusCode == 200) {
          print('Alarm $action successfully');
        } else {
          print('Failed to $action alarm: ${response.statusCode}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 일단 챗지피티가 짜준대로 만들었는데 창이 너무 커요.. dialog로 바꿔야할듯
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
              alarm['message'] ?? 'No message',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              alarm['created_at'] ?? 'Unknown',
              style: TextStyle(fontSize: 18),
            ),
            // 필요한 경우 추가 정보 표시
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _handleAlarmAction(
                        'accept',
                        alarm['sender_id'],
                        alarm['post_id'],
                        context); // TODO: 팀 멤버에 나 추가하고, 요청 보낸 사람에게 수락 알람 보내기
                    Navigator.of(context).pop(); // 알람 목록으로 돌아가기
                  },
                  child: Text('수락'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _handleAlarmAction(
                        'reject',
                        alarm['sender_id'],
                        alarm['post_id'],
                        context); // TODO: 요청 보낸 사람에게 거절 알람 보내기
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
