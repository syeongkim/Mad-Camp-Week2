import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'tabs/board.dart';
import 'tabs/chat.dart';
import 'tabs/profile.dart';
import 'services/login.dart';

void main() {
  KakaoSdk.init(nativeAppKey: 'ba7fb2ea07fc05c0d9bef2699731d508'); // 여기에 카카오 네이티브 앱 키를 입력하세요.
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
  bool isLoggedIn = false;

  void _login() {
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return MyHomePage();
    } else {
      return LoginScreen(onLogin: _login);
    }
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
    TeamChat(),
    MyProfile(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab Navigation Example'),
      ),
      body: _tabs[_currentIndex],
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
