import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CourseFormPage extends StatefulWidget {
  @override
  _CourseFormPageState createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  int? _userId = 0;
  String? _selectedCourse;
  String? _title;
  String? _comment;
  int? _capacity;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _courses = ['Course 1', 'Course 2', 'Course 3'];

  Future<void> _postSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //print('Nickname: $_nickname, Name: $_name, StudentID: $_studentID, Email: $_email');
      DateTime finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      String formattedDate = finalDateTime.toUtc().toIso8601String();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('userId');

      //회원가입 정보를 DB에 저장
      try {
        var postData = {
          'leader_id': _userId,
          'course_id': _selectedCourse,
          'post_title': _title,
          'post_content': _comment,
          'member_limit': _capacity,
          'due_date': formattedDate
        };

        final postteampostUri =
            Uri.parse('http://10.0.2.2:8000/teamposts/upload');
        http.Response postResponse = await http.post(
          postteampostUri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(postData),
        );

        // POST 요청 결과 확인
        if (postResponse.statusCode == 200) {
          print('POST 요청 성공: ${postResponse.body}');
        } else {
          print('POST 요청 실패: ${postResponse.statusCode}, ${postResponse.body}');
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('포스트 실패: $e'),
        ));
      }

      Navigator.pop(context, true);
      //요기 바꿔야함
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀플 등록'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '과목 선택'),
                value: _selectedCourse,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                  });
                },
                items: _courses.map((course) {
                  return DropdownMenuItem(
                    child: Text(course),
                    value: course,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
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
                  if (value == null || value.isEmpty) {
                    return '정원을 입력해주세요';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${_selectedDate!.toLocal()}'
                          .split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
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
    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime)
      setState(() {
        _selectedTime = pickedTime;
      });
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Course Form',
    home: CourseFormPage(),
  ));
}
