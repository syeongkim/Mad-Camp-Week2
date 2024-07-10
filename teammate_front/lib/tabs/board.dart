import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'newpost.dart'; // newpost.dart 파일 가져오기
import 'showpost.dart';
import 'alarm.dart';
import 'package:flutter/services.dart' show rootBundle;

class Board extends StatelessWidget {
  const Board({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'Pretendard',
        primarySwatch: Colors.blue,
      ),
      home: const SubjectList(),
    );
  }
}

class SubjectList extends StatefulWidget {
  const SubjectList({Key? key}) : super(key: key);

  @override
  State<SubjectList> createState() => SubjectListState();
}

class SubjectListState extends State<SubjectList> with SingleTickerProviderStateMixin{
  // List<String> subjects = [
  //   "Math 0", "Science 0", "History 0", "Math 10", "Science 10", "History 10", "Math 20", "Science 20", "History 20",
  // ]; // 예제 과목 목록
  List<String> subjects = [
    "CS101 프로그래밍기초", "CS109 프로그래밍 실습", "CS202 문제해결기법", "CS204 이산구조", "CS206 데이타구조", "CS211 디지탈시스템 및 실험", "CS220 프로그래밍의 이해", "CS230 시스템 프로그래밍", "CS270 지능 로봇 설계 및 프로그래밍", "CS300 알고리즘 개론", "CS310 내장형 컴퓨터 시스템", "CS311 전산기조직", "CS320 프로그래밍 언어", "CS322 형식언어 및 오토마타", "CS330 운영체제 및 실험", "CS341 전산망개론", "CS348 정보보호개론", "CS350 소프트웨어 공학개론", "CS360 데이타베이스 개론", "CS361 데이터 사이언스 개론", "CS370 심볼릭 프로그래밍", "CS371 딥러닝 개론", "CS372 파이썬을 통한 자연언어처리", "CS374 인간-컴퓨터 상호작용 개론", "CS376 기계학습", "CS380 컴퓨터그래픽스 개론", "CS402 전산논리학 개론", "CS408 전산학 프로젝트", "CS409 산학협업 소프트웨어 프로젝트", "CS411 인공지능을 위한 시스템", "CS420 컴파일러 설계", "CS422 계산이론", "CS423 확률적 프로그래밍", "CS431 동시성 프로그래밍", "CS442 모바일 컴퓨팅과 응용", "CS443 분산 알고리즘 및 시스템", "CS447 웹 보안 공격 실습", "CS453 소프트웨어 테스팅 자동화 기법", "CS454 인공 지능 기반 소프트웨어 공학", "CS457 스마트환경을 위한 요구공학", "CS458 소프트웨어 소스 코드 기반 동적 분석", "CS459 서비스 컴퓨팅 개론", "CS470 인공지능개론", "CS471 그래프 기계학습 및 마이닝", "CS473 소셜 컴퓨팅 개론", "CS474 텍스트마이닝", "CS475 자연언어처리를 위한 기계학습", "CS477 지능로봇공학 개론", "CS479 3차원 데이터를 위한 기계 학습", "CS481 데이터 시각화", "CS482 대화형 컴퓨터그래픽스", "CS483 기하학적 모델링 및 처리", "CS484 컴퓨터비전개론", "CS485 컴퓨터비전을 위한 기계학습", "CS486 웨어러블 사용자 인터페이스", "CS489 컴퓨터 윤리와 사회문제", "CS490 졸업연구", "CS492 전산학특강", "CS493 전산학 특강 I", "CS494 전산학특강 Ⅱ", "CS495 개별연구"
  ];

  Map<String, List<String>> categorizedSubjects = {};
  List<Map<String, dynamic>> allPosts = [];
  String? selectedCategory;
  String? selectedSubject;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool isAlarmPanelOpen = false;

  @override
  void initState() {
    super.initState();
    loadSubjects();
    loadposts();

    // 과목을 카테고리별로 분류
    for (var subject in subjects) {
      // String category = subject.split(' ')[1];
      String category = subject[2];
      if (!categorizedSubjects.containsKey(category)) {
        categorizedSubjects[category] = [];
      }
      categorizedSubjects[category]!.add(subject);
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(2, 0),
      end: Offset(1, 0),
    ).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.reverse();
    });
  }

  Future<void> loadSubjects() async {
    final String response = await rootBundle.loadString('course_list.json');
    final List<dynamic> data = await json.decode(response);
    setState(() {
      subjects = data
          .map<String>(
              (item) => "${item['course_code']} ${item['course_name']}")
          .toList();
      categorizeSubjects();
    });
  }

  void categorizeSubjects() {
    for (var subject in subjects) {
      String category = subject.split(' ')[0].substring(2, 3) + "00";
      if (!categorizedSubjects.containsKey(category)) {
        categorizedSubjects[category] = [];
      }
      categorizedSubjects[category]!.add(subject);
    }
  }

  Future<void> loadposts() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/teamposts/teamposts'));

      if (response.statusCode == 200) {
        setState(() {
          allPosts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
        print('All posts loaded: $allPosts');
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading all posts: $e');
    }
  }

  void _toggleAlarmPanel() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
      setState(() {
        isAlarmPanelOpen = false;
      });
    } else {
      setState(() {
        isAlarmPanelOpen = true;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await loadposts();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('과목 게시판'),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: _toggleAlarmPanel,
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          hint: Text("대분류 선택"),
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                              selectedSubject = null;
                            });
                          },
                          items: categorizedSubjects.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                "CS$value번대",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (selectedCategory != null)
                        Expanded(
                          child: DropdownButton<String>(
                            hint: Text("과목 선택"),
                            value: selectedSubject,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSubject = newValue;
                              });
                            },
                            items: categorizedSubjects[selectedCategory]!
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (selectedSubject != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubjectBoard(subject: selectedSubject!),
                              ),
                            ).then((_) => loadposts());
                          },
                          child: Text('이동'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allPosts.length,
                    itemBuilder: (context, index) {
                      var post = allPosts[index];
                      return ListTile(
                        title: Text(post['post_title'] ?? 'No Title'),
                        subtitle: Text(
                            '${post['course_id'] ?? 'N/A'}    Capacity: ${post['member_limit'] ?? 'N/A'}    Due: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(post['due_date']))}'),
                        isThreeLine: true,
                        onTap: () async {
                          bool isAvailable = await showPostDetailsDialog(
                              context, post, allPosts);
                          if (isAvailable) {
                            await loadposts();
                            post = allPosts[index];
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                color: Colors.grey[200],
                child: isAlarmPanelOpen ? AlarmList() : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class SubjectBoard extends StatefulWidget {
  final String subject;

  const SubjectBoard({Key? key, required this.subject}) : super(key: key);

  @override
  State<SubjectBoard> createState() => _SubjectBoardState();
}

class _SubjectBoardState extends State<SubjectBoard> {
  List<Map<String, dynamic>> subjectDetails = []; // 특정 과목의 전체 게시글

  @override
  void initState() {
    super.initState();
    loadSubjectDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadSubjectDetails();
  }

  Future<void> loadSubjectDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/teamposts/courses/${widget.subject}'),
      );

      if (response.statusCode == 200) {
        setState(() {

          // var temp = jsonDecode(response.body);
          // subjectDetails = List<Map<String, dynamic>>.from(temp);
          subjectDetails =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
          print("subject posts loaded");
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading subject details: $e');
    }
  }

  Future<void> savepost(
      String title, String comment, int capacity, DateTime dueDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    try {
      var postData = {
        'leader_id': userId,
        'course_id': widget.subject,
        'post_title': title,
        'post_content': comment,
        'member_limit': capacity,
        'due_date': dueDate.toUtc().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/teamposts/teamposts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        setState(() {
          subjectDetails.add(jsonDecode(response.body)); // 서버에서 반환된 데이터로 업데이트
        });
        await loadSubjectDetails();
      } else {
        print('Failed to save post: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  void _showAddPostForm() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPostPage(courseId: widget.subject), // 과목 ID 전달
      ),
    );

    // if (result != null && result is Map<String, dynamic>) {
    //   await savepost(
    //     result['title'],
    //     result['comment'],
    //     result['capacity'],
    //     result['dueDate'],
    //   );
    //
    // }
    await loadSubjectDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await loadSubjectDetails(); // db에서 불러와서 리스트에 저장
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.subject),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: subjectDetails.length,
                itemBuilder: (context, index) {
                  var post = subjectDetails[index];
                  return ListTile(
                    title: Text(
                        post['post_title'] ?? 'No Title'), // null인 경우 기본값 사용
                    subtitle: Text(
                        'Capacity: ${post['member_limit'] ?? 'N/A'}    Due: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(post['due_date']))}'),
                    isThreeLine: true,
                    onTap: () async {
                      bool isAvailable = await showPostDetailsDialog(
                          context, post, subjectDetails);
                      if (isAvailable) {
                        await loadSubjectDetails(); // 게시글 삭제 후 해당 과목의 게시글 목록 다시 불러오기
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddPostForm,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
