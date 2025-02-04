import 'package:flutter/material.dart';
import 'package:teammate_front/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammate_front/tabs/teamreview.dart';
import 'profile.dart';

class MyTeam extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white, // AppBar의 배경색
          foregroundColor: Color.fromRGBO(121, 18, 25, 1), // AppBar의 텍스트 및 아이콘 색상
        ),
        fontFamily: 'Chosun',
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      home: MT(), // MyTeams 화면으로 설정
    );
  }
}

class MT extends StatefulWidget {
  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MT> {
  List<Map<String, dynamic>> myTeample = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    await _fetchTeamData(userId!);
  }

  Future<void> _fetchTeamData(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('http://$apiurl:8000/teamposts/myteample/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          myTeample = List<Map<String, dynamic>>.from(data);
        });
        print("teample set successfully : ${myTeample}");
      } else {
        print(
            'Failed to load team data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching team data: $e');
    }
  }

  void _onTeamFinished() {
    _loadUserIdAndFetchData();
  }

  Future<List<Map<String, dynamic>>> _fetchTeamMembers(int teamId) async {
    final response = await http
        .get(Uri.parse('http://$apiurl:8000/teamposts/myteammember/$teamId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load team members');
    }
  }

  void _showTeamMembersDialog(int teamId) async {
    try {
      List<Map<String, dynamic>> teamMembers = await _fetchTeamMembers(teamId);
      Map<String, dynamic> teamInfo = await _fetchTeamInfo(teamId);
      int? currentUserId = await _getCurrentUserId();

      bool isLeader = currentUserId == teamInfo['leader_id'];
      bool isFull = teamInfo['is_full'];
      bool isFinished = teamInfo['is_finished'];

      // 현재 사용자 ID와 다른 멤버들의 ID만 추출
      List<int> memberIds = teamMembers
          .where((member) => member['user_id'] != currentUserId)
          .map<int>((member) => member['user_id'] as int)
          .toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(249, 214, 219, 1),
            title: Text('팀원 목록'),
            content: SingleChildScrollView(
              child: ListBody(
                children: teamMembers.map((member) {
                  return ListTile(
                    title: Text(member['name']),
                    subtitle: Text(member['student_id'].toString()),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            user_id: member['user_id'],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              if (isLeader && isFull && !isFinished)
                TextButton(
                  onPressed: () async {
                    await _finishTeam(teamId);
                    Navigator.of(context).pop();
                    _onTeamFinished();
                  },
                  child: Text('팀플 끝내기', style: TextStyle(color: Colors.black),),
                )
              else if (isFull && isFinished)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TeamReviewPage(memberIds: memberIds),
                      ),
                    );
                  },
                  child: Text('팀원 리뷰하기', style: TextStyle(color: Colors.black),),
                ),
              TextButton(
                child: Text('Close', style: TextStyle(color: Colors.black),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing team members dialog: $e');
    }
  }

  // Future<Map<String, dynamic>> _fetchTeamInfo(int teamId) async {
  //   final response =
  //       await http.get(Uri.parse('http://$apiurl:8000/teamposts/team/$teamId'));
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to load team info');
  //   }
  // }
  Future<Map<String, dynamic>> _fetchTeamInfo(int teamId) async {
    final response =
        await http.get(Uri.parse('http://$apiurl:8000/teamposts/team/$teamId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is List) {
        // Find the team with the specified teamId
        for (var team in data) {
          if (team['team_id'] == teamId) {
            return team as Map<String, dynamic>;
          }
        }
        throw Exception('Team with specified ID not found');
      } else if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load team info');
    }
  }

  Future<int?> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> _finishTeam(int teamId) async {
    final response = await http.put(
      Uri.parse('http://$apiurl:8000/teamposts/team/$teamId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'is_finished': true,
      }),
    );

    if (response.statusCode == 200) {
      print('Team finished successfully');
      _onTeamFinished();
    } else {
      throw Exception('Failed to finish team');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> inProgressTeams = myTeample
        .where(
            (team) => team['is_full'] == true && team['is_finished'] == false)
        .toList();
    List<Map<String, dynamic>> notStartedTeams = myTeample
        .where(
            (team) => team['is_full'] == false && team['is_finished'] == false)
        .toList();
    List<Map<String, dynamic>> finishedTeams = myTeample
        .where((team) => team['is_full'] == true && team['is_finished'] == true)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('나의 팀프로젝트', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserIdAndFetchData, // Pull to refresh
        child: ListView(
          children: [
            SectionTitle(title: "팀플 진행중"),
            TeamList(
              teams: inProgressTeams,
              showTeamMembersDialog: _showTeamMembersDialog,
            ),
            Divider(),
            SectionTitle(title: "팀플 진행전"),
            TeamList(
              teams: notStartedTeams,
              showTeamMembersDialog: _showTeamMembersDialog,
            ),
            Divider(),
            SectionTitle(title: "팀플 완료"),
            TeamList(
              teams: finishedTeams,
              showTeamMembersDialog: _showTeamMembersDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TeamList extends StatelessWidget {
  final List<Map<String, dynamic>> teams;
  final Function(int) showTeamMembersDialog;

  TeamList({
    required this.teams,
    required this.showTeamMembersDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: teams.map((team) {
        return ListTile(
          title: Text(team['course_id']),
          subtitle: Text('팀장: ${team['leader_name']}'),
          onTap: () {
            showTeamMembersDialog(team['team_id']);
          },
        );
      }).toList(),
    );
  }
}
