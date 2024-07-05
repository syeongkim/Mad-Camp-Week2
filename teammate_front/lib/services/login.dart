import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;

  LoginScreen({required this.onLogin});

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // 카카오톡 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();

      // 카카오톡으로 로그인 시도
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('카카오톡 로그인 성공: ${token.accessToken}');
      onLogin();
    } catch (e) {
      print('카카오톡 로그인 실패: $e');
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
