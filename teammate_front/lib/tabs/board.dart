import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'newpost.dart'; // newpost.dart 파일 가져오기
import 'showpost.dart';
import 'package:teammate_front/config.dart';

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

class SubjectListState extends State<SubjectList> {
  List<String> subjects = [
    "Math 0",
    "Science 0",
    "History 0",
    "Math 10",
    "Science 10",
    "History 10",
    "Math 20",
    "Science 20",
    "History 20",
  ]; // 예제 과목 목록

  Map<String, List<String>> categorizedSubjects = {};

  List<Map<String, dynamic>> allPosts = [];

  String? selectedCategory;
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    loadposts();
    // 과목을 카테고리별로 분류
    for (var subject in subjects) {
      String category = subject.split(' ')[1];
      if (!categorizedSubjects.containsKey(category)) {
        categorizedSubjects[category] = [];
      }
      categorizedSubjects[category]!.add(subject);
    }
  }

  Future<void> loadposts() async {
    try {
      final response =
          await http.get(Uri.parse('http://$apiurl:8000/teamposts/teamposts'));

      if (response.statusCode == 200) {
        setState(() {
          allPosts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
        // print('All posts loaded: $allPosts');
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading all posts: $e');
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
          title: Text('과목 선택'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text("섹션 선택"),
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                          selectedSubject = null; // 섹션이 변경되면 과목 선택 초기화
                        });
                      },
                      items: categorizedSubjects.keys
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
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
                            child: Text(value),
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
                        ).then((_) => loadposts()); // 돌아왔을 때 전체 기사 로드
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
                    title: Text(
                        post['post_title'] ?? 'No Title'), // null인 경우 기본값 사용
                    subtitle: Text(
                        '${post['course_id'] ?? 'N/A'} Capacity: ${post['member_limit'] ?? 'N/A'} Due: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(post['due_date'] ?? DateTime.now().toString()))}'),

                    isThreeLine: true,
                    onTap: () async {
                      bool isAvailable =
                          await showPostDetailsDialog(context, post, allPosts);
                      if (isAvailable) loadposts();
                      post = allPosts[index];
                    },
                  );

                  //  setState(() {
                  //     subjectDetails = List<Map<String, dynamic>>.from(jsonDecode(response.body));
                  //   });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectBoard extends StatefulWidget {
  final String subject;

  const SubjectBoard({Key? key, required this.subject}) : super(key: key);

  @override
  State<SubjectBoard> createState() => _SubjectBoardState();
}

class _SubjectBoardState extends State<SubjectBoard> {
  List<Map<String, dynamic>> subjectDetails = []; //특정 과목의 전체 게시글

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
      print(widget.subject);
      final response = await http.get(
        Uri.parse('http://$apiurl:8000/teamposts/courses/${widget.subject}'),
      );

      if (response.statusCode == 200) {
        setState(() {
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
        Uri.parse('http://$apiurl:8000/teamposts/upload'),
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
        //await _updateSubjectposts();
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

    //여기에서 방금 저장한 포스트까지 반영해서 불러오기
    try {
      final response = await http.get(
          Uri.parse('http://$apiurl:8000/teamposts/courses/${widget.subject}'));

      if (response.statusCode == 200) {
        setState(() {
          subjectDetails =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
        print('All posts loaded: $subjectDetails');
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading all posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await loadSubjectDetails(); //db에서 불러옴 와서 리스트에 저장
        //await _updateSubjectposts();
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
                        'Capacity: ${post['member_limit'] ?? 'N/A'} Due: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(post['due_date'] ?? DateTime.now().toString()))}'),
                    isThreeLine: true,
                    onTap: () async {
                      bool isAvailable = await showPostDetailsDialog(
                          context, post, subjectDetails);
                      if (isAvailable) loadSubjectDetails();
                      post = subjectDetails[index];
                    },
                    // onTap: () => _showPostDetailsDialog(context, post),
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
