import 'package:flutter/material.dart';

import 'common.dart';
import 'dbhelper.dart';

class InactivityTrackerPage extends StatefulWidget {
  @override
  _InactivityTrackerPageState createState() => _InactivityTrackerPageState();
}

class _InactivityTrackerPageState extends State<InactivityTrackerPage> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _addContact(String name, String contact, String email) async {
    setState(() {
      Common.contacts.add({'name': name, 'contact': contact, 'email': email});
    });
    if(Common.username!=null){
      await dbHelper.updateContacts(Common.username!, Common.contacts);
    }
  }

  void _deleteContact(int index) async {
    setState(() {
      Common.contacts.removeAt(index);
    });
    if(Common.username!=null){
      await dbHelper.updateContacts(Common.username!, Common.contacts);
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _contactController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty) {
                  _addContact(
                    _nameController.text,
                    _contactController.text,
                    _emailController.text,
                  );
                  _nameController.clear();
                  _contactController.clear();
                  _emailController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inactivity Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: Common.contacts.length,
                itemBuilder: (context, index) {
                  final contact = Common.contacts[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(contact['name'] ?? ''),
                      subtitle: Text(
                          'Phone: ${contact['contact'] ?? ''}\nEmail: ${contact['email'] ?? ''}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        onPressed: () => _deleteContact(index),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
