import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'tabs/board.dart';
import 'tabs/chat.dart';
import 'tabs/mypage.dart';
import 'tabs/newpost.dart';
import 'services/login.dart';

void main() {
  KakaoSdk.init(
      nativeAppKey:
          'ba7fb2ea07fc05c0d9bef2699731d508'); // 여기에 카카오 네이티브 앱 키를 입력하세요.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tab Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<bool?> getLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedin');
  }

  Future<void> saveLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedin', true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: getLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중인 상태를 나타내는 로딩 인디케이터 표시
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // 오류 발생 시 오류 메시지 표시
          return Scaffold(
            body: Center(
              child: Text('오류 발생: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          // 로그인된 상태
          return MyHomePage();
        } else {
          // 로그인되지 않은 상태
          return LoginScreen(onLogin: () async {
            await saveLogin();
            setState(() {}); // 상태 변경을 트리거하여 UI를 업데이트
          });
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    Board(),
    CourseFormPage(),
    MyPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Tab Navigation Example'),
      // ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '팀챗',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내프로필',
          ),
        ],
      ),
    );
  }
}
