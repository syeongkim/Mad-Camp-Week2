import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammate_front/config.dart';
import 'profile.dart';

class MyTeam extends StatefulWidget {
  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeam> {
  List<Map<String, dynamic>> myTeample = [];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    await _fetchTeamData(userId!);
  }

  Future<void> _fetchTeamData(userId) async {
    userId = userId.toString();
    print(userId);

    final response = await http
        .get(Uri.parse('http://$apiurl:8000/teamposts/myteample/$userId'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        myTeample = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load team data');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTeamMembers(teamId) async {
    var team_id = teamId.toString();
    print(team_id);
    final response = await http
        .get(Uri.parse('http://$apiurl:8000/teamposts/myteammember/$team_id'));
    print(response.body);
    if (response.statusCode == 200) {
      print('여기에러1');
      List<dynamic> data = json.decode(response.body);
      print('여기에러2');
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load team members');
    }
  }

  void _showTeamMembersDialog(int teamId) async {
    List<Map<String, dynamic>> teamMembers = await _fetchTeamMembers(teamId);
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
                    // 팀 멤버 클릭 시 수행할 동작
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
      body: ListView(
        children: [
          SectionTitle(title: "팀플 진행중"),
          TeamList(
              teams: inProgressTeams,
              showTeamMembersDialog: _showTeamMembersDialog),
          Divider(),
          SectionTitle(title: "팀플 진행전"),
          TeamList(
              teams: notStartedTeams,
              showTeamMembersDialog: _showTeamMembersDialog),
          Divider(),
          SectionTitle(title: "팀플 완료"),
          TeamList(
              teams: finishedTeams,
              showTeamMembersDialog: _showTeamMembersDialog),
        ],
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

  TeamList({required this.teams, required this.showTeamMembersDialog});

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
