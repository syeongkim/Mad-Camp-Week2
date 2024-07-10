import 'package:flutter/material.dart';
import 'package:teammate_front/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammate_front/tabs/teamreview.dart';
import 'profile.dart';

class MyTeam extends StatefulWidget {
  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeam> {
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
          title: Text('Team Members'),
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
                  // _onTeamFinished(); 없어도 되는 줄 같은데 일단은 주석처리 해봄
                },
                child: Text('팀플 끝내기'),
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
                child: Text('팀원 리뷰하기'),
              ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchTeamInfo(int teamId) async {
    final response =
        await http.get(Uri.parse('http://$apiurl:8000/teamposts/team/$teamId'));
    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
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
      appBar: AppBar(
        title: Text('My Teams'),
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
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
