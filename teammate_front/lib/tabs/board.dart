import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    "Math 0", "Science 0", "History 0",
    "Math 10", "Science 10", "History 10",
    "Math 20", "Science 20", "History 20",
  ]; // 예제 과목 목록

  Map<String, List<String>> categorizedSubjects = {};

  List<String> allArticles = [];

  String? selectedCategory;
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    loadArticles();
    // 과목을 카테고리별로 분류
    for (var subject in subjects) {
      String category = subject.split(' ')[1];
      if (!categorizedSubjects.containsKey(category)) {
        categorizedSubjects[category] = [];
      }
      categorizedSubjects[category]!.add(subject);
    }
  }

  Future<void> loadArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      allArticles = prefs.getStringList('allArticles') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    items: categorizedSubjects.keys.map<DropdownMenuItem<String>>((String value) {
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
                      items: categorizedSubjects[selectedCategory]!.map<DropdownMenuItem<String>>((String value) {
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
                          builder: (context) => SubjectBoard(subject: selectedSubject!),
                        ),
                      ).then((_) => loadArticles()); // 돌아왔을 때 전체 기사 로드
                    },
                    child: Text('이동'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allArticles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(allArticles[index]),
                );
              },
            ),
          ),
        ],
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
  List<String> subjectDetails = [];

  @override
  void initState() {
    super.initState();
    loadSubjectDetails();
  }

  Future<void> loadSubjectDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedArticles = prefs.getString(widget.subject);
    if (storedArticles != null) {
      setState(() {
        subjectDetails = List<String>.from(jsonDecode(storedArticles));
      });
    } else {
      setState(() {
        subjectDetails = getSubjectDetails(widget.subject);
      });
    }
  }

  Future<void> saveArticle(String article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    subjectDetails.add(article);
    await prefs.setString(widget.subject, jsonEncode(subjectDetails));

    List<String> allArticles = prefs.getStringList('allArticles') ?? [];
    allArticles.add(article);
    await prefs.setStringList('allArticles', allArticles);
  }

  void _showAddArticleDialog() {
    TextEditingController articleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add new article"),
          content: TextField(
            controller: articleController,
            decoration: InputDecoration(
              hintText: "Enter article title",
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () async {
                if (articleController.text.isNotEmpty) {
                  await saveArticle(articleController.text);
                  setState(() {
                    subjectDetails.add(articleController.text);
                  });
                  articleController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      articleController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: subjectDetails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(subjectDetails[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  List<String> getSubjectDetails(String subject) {
    // 과목에 따라 다른 기사 목록을 반환하는 예제
    if (subject == "Math 0") {
      return ["Math 0 Article 1", "Math 0 Article 2", "Math 0 Article 3"];
    } else if (subject == "Science 0") {
      return ["Science 0 Article 1", "Science 0 Article 2", "Science 0 Article 3"];
    }
    // 여기에 다른 과목에 대한 기사 목록 추가
    return ["Default Article 1", "Default Article 2", "Default Article 3"];
  }
}
