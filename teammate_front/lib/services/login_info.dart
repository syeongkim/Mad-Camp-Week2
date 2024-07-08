import 'package:flutter/material.dart';

class LoginInfo extends StatefulWidget {
  @override
  _LoginInfoState createState() => _LoginInfoState();
}

class _LoginInfoState extends State<LoginInfo> {
  final _formKey = GlobalKey<FormState>();
  String _nickname = '';
  String _name = '';
  String _studentID = '';
  String _email = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // 입력받은 정보 처리 로직을 여기에 추가합니다.
      print('Nickname: $_nickname, Name: $_name, StudentID: $_studentID, Email: $_email');
      
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
                  _name = value!;
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
                  _nickname = value!;
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
                  _studentID = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
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
