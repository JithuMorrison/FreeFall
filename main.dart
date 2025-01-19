import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freefall/loginpage.dart';
import 'package:workmanager/workmanager.dart';
import 'common.dart';
import 'dbhelper.dart';
import 'homepage.dart';

const String backgroundTaskKey = "checkValueTask";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  //await Workmanager().cancelAll();
  // Start periodic background task
  ///*
  Workmanager().registerPeriodicTask(
    "1", // Unique task identifier
    backgroundTaskKey,
    frequency: const Duration(minutes: 15), // Executes every 15 hour
  );
  //*/
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundTaskKey) {
      await checkValueAndNotify();
    }
    return Future.value(true);
  });
}

Future<void> checkValueAndNotify() async {
  final dbHelper = DatabaseHelper();
  final username = Common.username ?? await fetchFirstUsername();
  final contacts = await dbHelper.getContacts(username);
  final currentValue = _generateRandomValue(40, 100);
  if (currentValue < 50.0) {
    await sendNotification("Alert!", "$username, value has fallen below the threshold: $currentValue and contacts: ${contacts}");
    await updateCondition(true); // Update condition for UI
  } else {
    await sendNotification("Alert!", "$username, no new falls");
    await updateCondition(false); // Update condition for UI
  }
  print(currentValue);
}

Future<String> fetchFirstUsername() async {
  final dbHelper = DatabaseHelper(); // Assuming DatabaseHelper is your database manager class
  final db = await dbHelper.database;

  // Fetch the first row from the 'users' table
  final List<Map<String, dynamic>> result = await db.query(
    'users',
    columns: ['username'],
    limit: 1,
  );

  // If the table is empty, return a default value
  if (result.isEmpty) {
    return 'User';
  }

  // Return the username from the first row
  return result.first['username'] as String;
}

double _generateRandomValue(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min + 1).toDouble();
}

Future<void> updateCondition(bool hasFallen) async {
  // Store the "fall" status in a persistent way (use shared_preferences or similar)
  // For simplicity, using static variable (not persistent)
  HomePage.hasFallen = hasFallen;
}

// Send a local notification
Future<void> sendNotification(String title, String body) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformChannelSpecifics,
  );
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
      home: LoginPage(),
    );
  }
}
