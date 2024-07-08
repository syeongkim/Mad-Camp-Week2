import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
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

    try {
      // 카카오 계정으로 로그인 시도
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오 계정으로 로그인 성공: ${token.accessToken}');
      // 로그인 성공 시, 토큰을 사용하여 서버에 요청
      final Uri uri = Uri.parse('http://10.0.2.2:8000/oauth/callback').replace(
        queryParameters: {
          'access_token': token.accessToken,
        },
      );
      print('서버 요청: $uri');
      http.Response response = await http.get(uri);
      Map<String, dynamic> response_dict = jsonDecode(response.body);

      // //회원가입 프론트 - 서버 통신 임시 코드 시작 (추후 registter.dart로 이동)
      // try {
      //   var userId = response_dict['id'];
      //   var userName = "윤우성";
      //   var userNickname = "몰입캠프힘드러";
      //   var userStudentId = "202311123";

      //   var postData = {
      //     'user_id': userId,
      //     'user_name': userName,
      //     'user_nickname': userNickname,
      //     'user_student_id': userStudentId,
      //   };

      //   final postregisterUri = Uri.parse('http://10.0.2.2:8000/user/register/');
      //   http.Response postResponse = await http.post(
      //     postregisterUri,
      //     headers: {
      //       'Content-Type': 'application/json',
      //     },
      //     body: jsonEncode(postData),
      //   );

      //   // POST 요청 결과 확인
      //   if (postResponse.statusCode == 200) {
      //     print('POST 요청 성공: ${postResponse.body}');
      //   } else {
      //     print('POST 요청 실패: ${postResponse.statusCode}');
      //   }
      // } catch (e) {
      //   // 로그인 실패 시, 스낵바를 통해 사용자에게 알림
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text('카카오 로그인 실패: $e'),
      //   ));

      // //회원가입 프론트 - 서버 통신 임시 코드 끝 (추후 registter.dart로 이동)

      print('서버 응답: $response_dict');
      if (response_dict['is_exist'] == true) {
        print("User is already created");
        onLogin();
      } else {
        print("User is not created");
        onLogin();
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
