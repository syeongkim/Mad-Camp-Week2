import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginInfo extends StatefulWidget {
  // final VoidCallback onLogin;

  // LoginInfo({required this.onLogin});

  @override
  _LoginInfoState createState() => _LoginInfoState();
}

class _LoginInfoState extends State<LoginInfo> {
  final _formKey = GlobalKey<FormState>();
  int? _userId = 0;
  String _nickname = '';
  String _name = '';
  int _studentID = 0;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //print('Nickname: $_nickname, Name: $_name, StudentID: $_studentID, Email: $_email');
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('userId');


      //회원가입 정보를 DB에 저장
      try {
        // var userId = _userId;
        // var userName = "윤우성";
        // var userNickname = "몰입캠프힘드러";
        // var userStudentId = 202311123;

        var postData = {
          'user_id': _userId,
          'user_name': _name,
          'user_nickname': _nickname,
          'user_student_id': _studentID,
        };

        final postregisterUri = Uri.parse('http://10.0.2.2:8000/user/register');
        http.Response postResponse = await http.post(
          postregisterUri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(postData),
        );

        // POST 요청 결과 확인
        if (postResponse.statusCode == 200) {
          print('POST 요청 성공: ${postResponse.body}');
          // widget.onLogin();
        } else {
          print('POST 요청 실패: ${postResponse.statusCode}');
        }
      } catch (e) {
        print(e);
        // 로그인 실패 시, 스낵바를 통해 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('카카오 로그인 실패: $e'),
        ));

        //회원가입 프론트 - 서버 통신 임시 코드 끝 (추후 registter.dart로 이동)
      }

      // 입력 완료 후 LoginScreen으로 돌아감
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nickname';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nickname = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'StudentID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your studentID';
                  }
                  return null;
                },
                onSaved: (value) {
                  _studentID = int.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
