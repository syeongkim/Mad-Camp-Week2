import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:teammate_front/config.dart';

class NewPostPage extends StatefulWidget {
  final String courseId;

  NewPostPage({required this.courseId});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _comment;
  int? _capacity;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _showDateError = false;
  bool _showTimeError = false;

  Future<void> _postSubmit() async {
    setState(() {
      _showDateError = _selectedDate == null;
      _showTimeError = _selectedTime == null;
    });

    if (_formKey.currentState!.validate() &&
        !_showDateError &&
        !_showTimeError) {
      _formKey.currentState!.save();

      DateTime finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');
      String course_code = widget.courseId.split(' ')[0];
      print(course_code);

       //adding post
      var postData = {
        'leader_id': userId,
        'course_id': course_code, // 실제 course_id를 전달
        'post_title': _title,
        'post_content': _comment,
        'member_limit': _capacity,
        'due_date': finalDateTime.toUtc().toIso8601String(),
      };

      try {
        final response = await http.post(
          Uri.parse('http://$apiurl:8000/teamposts/teamposts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(postData),
        );

        if (response.statusCode == 200) {
          // Navigator.pop(context, {
          //   'title': _title,
          //   'comment': _comment,
          //   'capacity': _capacity,
          //   'dueDate': finalDateTime,
          // });
          print("data saved successfully");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save post: ${response.statusCode}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }

      //adding team
      final response =
      await http.get(Uri.parse('http://$apiurl:8000/teamposts/teamposts'));
      if (response.statusCode == 200) {
        print('all posts get success');
      } else {
        throw Exception('Failed to load all posts');
      }
      var posts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      print(posts.length);
      // var post = posts[posts.length-1];
      int team_id = posts.length;
      // int team_id = post['post_id'];
      // print(team_id);


      // int teamlength = 0;
      // final response =
      // await http.get(Uri.parse('http://$apiurl:8000/teamposts/courses/${widget.courseId}'));
      // if (response.statusCode == 200) {
      //   print('course info get success');
      // } else {
      //   throw Exception('Failed to load team info');
      // }
      // final response2 = await http.get(Uri.parse('http://$apiurl:8000/teamposts/team'));
      // if (response2.statusCode == 200) {
      //   List<Map<String, dynamic>> teams = [];
      //   teams = json.decode(response2.body) as List<Map<String, dynamic>>;
      //   //teams = List<Map<String, dynamic>>.from(jsonDecode(response2.body));
      //   teamlength = teams.length;
      //   print('all team get success');
      // } else {
      //   throw Exception('Failed to load all team');
      // }
      // List<Map<String, dynamic>> posts = [];
      // posts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      // var post = posts[teamlength-1];
      // int team_id = post['post_id'];
      var teamData = {
        'team_id': team_id, 
        'course_id': widget.courseId,
        'leader_id': userId,
      };

      try {
        final response = await http.post(
          Uri.parse('http://$apiurl:8000/teamposts/team'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(teamData),
        );
        
        if (response.statusCode == 200) {
          print("team created successfully");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to create team: ${response.statusCode}'),
          ));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
          ));
        }
      

      //adding teamleader as teammember
      var memberData = {
        'team_id': team_id,
        'member_id': userId,
      };

      try {
        final response = await http.post(
          Uri.parse('http://$apiurl:8000/teamposts/team/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(memberData),
        );

        if (response.statusCode == 200) {
          print("team member added successfully");
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add team member: ${response.statusCode}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '팀플 제목'),
                onSaved: (newValue) {
                  _title = newValue;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '팀플 설명'),
                onSaved: (newValue) {
                  _comment = newValue;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '정원'),
                keyboardType: TextInputType.number,
                onSaved: (newValue) {
                  if (newValue != null && newValue.isNotEmpty) {
                    _capacity = int.tryParse(newValue);
                  }
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value)! < 2) {
                    return '2명 이상의 정원을 입력해주세요';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              if (_showDateError)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '날짜를 선택해주세요',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : 'Selected Time: ${_selectedTime!.format(context)}',
                ),
                trailing: Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              if (_showTimeError)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '시간을 선택해주세요',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _postSubmit,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _showDateError = false; // 날짜 선택 시 경고 메시지 숨기기
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _showTimeError = false; // 시간 선택 시 경고 메시지 숨기기
      });
    }
  }
}
