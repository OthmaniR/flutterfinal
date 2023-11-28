import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentManagementScreen extends StatefulWidget {
  final String classId;
  final String className;

  // Define the classId parameter in the constructor
  StudentManagementScreen({required this.classId, required this.className});

  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudentsForClass(widget.classId);
  }

  Future<void> fetchStudentsForClass(String classId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8082/classes/$classId/etudiants'));

      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        print('Response Data: $data');

        if (data.containsKey('_embedded') && data['_embedded'] is Map<String, dynamic>) {
          dynamic embeddedData = data['_embedded'];
          if (embeddedData.containsKey('etudiants') && embeddedData['etudiants'] is List) {
            setState(() {
              students = List<Map<String, dynamic>>.from(embeddedData['etudiants']);
            });
          } else {
            throw Exception('Invalid data format: expected List inside _embedded, but received ${embeddedData['etudiants'].runtimeType}');
          }
        } else {
          throw Exception('Invalid data format: expected _embedded object, but received ${data['_embedded'].runtimeType}');
        }
      } else {
        throw Exception('Failed to load students. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching students: $error');
    }
  }

  Future<void> addStudent(String studentName, String lastName) async {
    try {
      final response = await http.post(
          Uri.parse('http://10.0.2.2:8082/classes/etudiants/addStudent'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'nom': studentName,
            'prenom': lastName,
            'dateNais': '2023-11-21'

          })


      );

      print('Response Status Code: ${response.statusCode}');
      print('ooooooooooooooooooooooooooooooooooooo: ${widget.classId}');

      if (response.statusCode == 201) {
        fetchStudentsForClass(widget.classId);
      } else {
        throw Exception('Failed to add a new student');
      }
    } catch (error) {
  print('Error adding a new student: $error');
  }
}

Future<void> updateStudent(int studentId, String studentName, String lastName) async {
  try {
    final response = await http.put(
        Uri.parse('http://10.0.2.2:8082/classes/etudiants/updateStudent/$studentId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nom': studentName,
          'prenom': lastName,
          'dateNais': '2023-11-21', // Example date; adjust accordingly

        }));

    if (response.statusCode == 200) {
      fetchStudentsForClass(widget.classId);
    } else {
      throw Exception('Failed to update the student');
    }
  } catch (error) {
print('Error updating the student: $error');
}
}

Future<void> deleteStudent(int studentId) async {
try {
final response = await http.delete(
Uri.parse('http://10.0.2.2:8082/classes/etudiants/deleteStudent/$studentId'),
headers: {
'Content-Type': 'application/json',
},
);

if (response.statusCode == 204) {
fetchStudentsForClass(widget.classId);
} else if (response.statusCode == 404) {
print('Student not found');
} else {
throw Exception('Failed to delete the student');
}
} catch (error) {
print('Error deleting the student: $error');
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Students for ${widget.className}'),
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
// Display students here using the 'students' list

// Example: Display student names in a ListView
Expanded(
child: ListView.builder(
itemCount: students.length,
itemBuilder: (context, index) {
return ListTile(
title: Text(students[index]['nom'] ?? 'N/A'),
subtitle: Text('ID: ${students[index]['id'] ?? 'N/A'}'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
ElevatedButton(
onPressed: () {
_showUpdateStudentPopup(context,index);
  // Pass the student details to the updateStudent function

},
child: Text('Update'),
),
SizedBox(width: 8),
ElevatedButton(
onPressed: () {
// Handle delete logic here
deleteStudent(students[index]['id']);
},
style: ElevatedButton.styleFrom(
primary: Colors.red,
),
child: Text('Delete'),
),
],
),
);
},
),
),
],
),
),
floatingActionButton: FloatingActionButton(
onPressed: () {
_showAddStudentPopup(context);
},
tooltip: 'Add Student',
child: Icon(Icons.add),
),
);
}
  void _showUpdateStudentPopup(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentUpdateNameController,
                decoration: InputDecoration(labelText: 'Student New Name'),
              ),
              TextField(
                controller: studentUpdateLastNameController,
                decoration: InputDecoration(labelText: 'Student New Last Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add the new student by calling the addStudent function
                updateStudent(students[index]['id'], studentUpdateNameController.text, studentUpdateLastNameController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

void _showAddStudentPopup(BuildContext context) {
showDialog(
context: context,
builder: (BuildContext context) {
return AlertDialog(
title: Text('Add New Student'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: studentNameController,
decoration: InputDecoration(labelText: 'Student Name'),
),
TextField(
controller: studentLastNameController,
decoration: InputDecoration(labelText: 'Student Last Name'),
),
],
),
////

actions: <Widget>[
TextButton(
onPressed: () {
Navigator.of(context).pop();
},
child: Text('Cancel'),
),
TextButton(
onPressed: () {
// Add the new student by calling the addStudent function
addStudent(studentNameController.text, studentLastNameController.text);
Navigator.of(context).pop();
},
child: Text('Add'),
),
],
);
},
);
}

// Declare your text editing controllers at the top of the class
final TextEditingController studentNameController = TextEditingController();
final TextEditingController studentLastNameController = TextEditingController();
  final TextEditingController studentUpdateNameController = TextEditingController();
  final TextEditingController studentUpdateLastNameController = TextEditingController();
}
