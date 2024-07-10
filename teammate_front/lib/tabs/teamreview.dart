import 'package:flutter/material.dart';

class TeamReviewPage extends StatelessWidget {
  final List<int> memberIds;

  TeamReviewPage({required this.memberIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Review'),
      ),
      body: ListView.builder(
        itemCount: memberIds.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Member ID: ${memberIds[index]}'),
          );
        },
      ),
    );
  }
}
