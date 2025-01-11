import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, String> userProfile;

  // Accept user profile as input
  const ProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TextEditingControllers to manage user input
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Example: Simulate editing or saving functionality
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the values passed from the user profile
    nameController = TextEditingController(text: widget.userProfile['name']);
    emailController = TextEditingController(text: widget.userProfile['email']);
    phoneController = TextEditingController(text: widget.userProfile['phone']);
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() {
    // Simulate saving logic (you can send this data to an API or save locally)
    print("Name: ${nameController.text}");
    print("Email: ${emailController.text}");
    print("Phone: ${phoneController.text}");
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: nameController,
            enabled: isEditing,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: emailController,
            enabled: isEditing,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: phoneController,
            enabled: isEditing,
            decoration: InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: toggleEdit,
                child: Text(isEditing ? 'Cancel' : 'Edit'),
              ),
              ElevatedButton(
                onPressed: isEditing ? saveProfile : null,
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free memory
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
