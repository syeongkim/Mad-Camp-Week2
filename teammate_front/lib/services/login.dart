import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:teammate_front/config.dart';
import 'login_info.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;

  LoginScreen({required this.onLogin});

  Future<void> _loginWithKakao(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kakao login is not supported on this platform.'),
      ));
      return;
    }

    //여기에서 isUser에 유저인지 여부를 받아올 예정
    // bool isUser = false;

    // //새로운 유저의 회원가입
    // if (isUser == false) {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => LoginInfo(),
    //     ),
    //   );
    // }

    // 로그인 성공 처리
    // onLogin();

    // try {
    //   // 카카오 계정으로 로그인 시도
    //   OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
    //   print('카카오 계정으로 로그인 성공: ${token.accessToken}');
    //   // 로그인 성공 시, 토큰을 사용하여 서버에 요청
    //   final Uri uri = Uri.parse('http://$apiurl:8000/oauth/callback').replace(
    //     queryParameters: {
    //       'access_token': token.accessToken,
    //     },
    //   );
    //   print('서버 요청: $uri');
    //   http.Response response = await http.get(uri);
    //   print('서버 응답: ${response.body}');
    //   var responseDict = json.decode(response.body) as Map<String, dynamic>;
    //   print(responseDict);

    //   //유저 id를 로컬에 저장
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.setInt('userId', responseDict['id']);

    //   print('서버 응답: $responseDict');
    //   if (responseDict['is_exist'] == true) {
    //     print("User is already created");
    //     onLogin();
    //   } else {
    //     print("User is not created");
    //     bool infoDone = await Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (context) => LoginInfo(),
    //       ),
    //     );
    //     print("hi");
    //     if (infoDone == true) {
    //       onLogin();
    //     } else {
    //       _loginWithKakao(context);
    //     }
    //   }
    // } catch (e) {
    //   // 로그인 실패 시, 스낵바를 통해 사용자에게 알림
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('카카오 로그인 실패: $e'),
    //   ));
    // }
    try {
      // 카카오 계정으로 로그인 시도
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오 계정으로 로그인 성공: ${token.accessToken}');
      // 로그인 성공 시, 토큰을 사용하여 서버에 요청
      final Uri uri = Uri.parse('http://$apiurl:8000/oauth/callback').replace(
        queryParameters: {
          'access_token': token.accessToken,
        },
      );
      print('서버 요청: $uri');
      http.Response response = await http.get(uri);
      print('서버 응답: ${response.body}');
      var responseDict = json.decode(response.body) as Map<String, dynamic>;
      print(responseDict);

      //유저 id를 로컬에 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', responseDict['id']);

      print('서버 응답: $responseDict');
      if (responseDict['is_exist'] == true) {
        print("User is already created");
        onLogin();
      } else {
        print("User is not created");
        bool infoDone = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoginInfo(),
          ),
        );
        print("hi");
        if (infoDone == true) {
          onLogin();
        } else {
          _loginWithKakao(context);
        }
      }
    } catch (e) {
      // 로그인 실패 시, 스낵바를 통해 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('카카오 로그인 실패: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _loginWithKakao(context),
          child: Text('Login with Kakao'),
        ),
      ),
    );
  }
}
