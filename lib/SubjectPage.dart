import 'dart:convert';

import 'package:flutter/material.dart';

import 'Matiere.dart';

import 'package:http/http.dart' as http;

class SubjectPage extends StatefulWidget {
  final String classId;
  final String className; // Add the className parameter

  // Constructor to initialize the classId and className parameters
  SubjectPage({required this.classId, required this.className});

  @override
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  // Your implementation for the SubjectPageState

  Future<List<Matiere>> fetchSubjectsByClass(int classCode) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8082/classes/subjects/$classCode'),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the subjects
      final List<dynamic> data = json.decode(response.body);
      return data.map((subject) => Matiere.fromJson(subject)).toList();
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load subjects');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Your implementation for building the SubjectPage UI
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects for Class ${widget.className}'),
      ),
      body: Center(
        // Your SubjectPage UI components
      ),
    );
  }
}