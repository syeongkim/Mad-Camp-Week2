import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

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
      // 카카오 계정으로 바로 로그인 시도
      print('여기까지옴');
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('여기도옴');
      print('카카오 계정으로 로그인 성공: ${token.accessToken}');

      // 로그인 성공 처리
      onLogin();
    
    } catch (e) {
  print('카카오 로그인 실패: $e');
  if (e is KakaoAuthException) {
    print('KakaoAuthException: ${e.message}');
  } else if (e is KakaoClientException) {
    print('KakaoClientException: ${e.message}');
  } else {
    print('Unknown error: $e');
  }
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
