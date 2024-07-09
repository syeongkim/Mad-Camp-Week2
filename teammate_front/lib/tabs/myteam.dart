import 'package:flutter/material.dart';
import 'package:teammate_front/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _fetchTeamData(int userId) async {
    final response = await http
        .get(Uri.parse('http://$apiurl:8000/teamposts/myteample/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        myTeample = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load team data');
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
                  _onTeamFinished();
                },
                child: Text('팀플 끝내기'),
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
      body: ListView(
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


// class TeamList extends StatefulWidget {
//   final List<Map<String, dynamic>> teams;
//   final Function(int) showTeamMembersDialog;
//   final Function onTeamFinished;

//   TeamList({
//     required this.teams,
//     required this.showTeamMembersDialog,
//     required this.onTeamFinished,
//   });

//   @override
//   _TeamListState createState() => _TeamListState();
// }

// class _TeamListState extends State<TeamList> {
//   Future<void> _finishTeam(int teamId) async {
//     final response = await http.put(
//       Uri.parse('http://$apiurl:8000/teamposts/team/$teamId'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'is_finished': true,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('Team finished successfully');
//       widget.onTeamFinished();
//     } else {
//       throw Exception('Failed to finish team');
//     }
//   }

//   Future<int?> _getCurrentUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('userId');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: widget.teams.map((team) {
//         return ListTile(
//           title: Text(team['course_id']),
//           subtitle: Text('팀장: ${team['leader_name']}'),
//           onTap: () {
//             widget.showTeamMembersDialog(team['team_id']);
//           },
//           trailing: FutureBuilder<int?>(
//             future: _getCurrentUserId(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               } else if (snapshot.hasError) {
//                 return Text('Error');
//               } else if (snapshot.hasData) {
//                 int? userId = snapshot.data;
//                 if (userId == team['leader_id'] &&
//                     team['is_full'] == true &&
//                     team['is_finished'] == false) {
//                   return TextButton(
//                     onPressed: () async {
//                       await _finishTeam(team['team_id']);
//                     },
//                     child: Text('팀플 끝내기'),
//                   );
//                 }
//               }
//               return Container(); // Default case to return an empty container if conditions are not met
//             },
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
