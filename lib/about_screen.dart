import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: 1.0.0'),
            SizedBox(height: 10),
            Text('Developer Info:'),
            Text('Name: Matthias Fichtinger'),
            Text('Skills: Flutter, Dart, Firebase'),
          ],
        ),
      ),
    );
  }
}
