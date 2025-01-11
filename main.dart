import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

// Notifications Page
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Text(
                  'O',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text('Oliver'),
              subtitle: Text('Sample text notifications go here'),
              trailing: Icon(Icons.clear, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
