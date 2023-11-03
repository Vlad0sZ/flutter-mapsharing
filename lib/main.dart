import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sharing_map/admin_area/map_editor.dart';
import 'package:sharing_map/database/db.dart';
import 'package:sharing_map/database/firebase_db.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Database.instantiate(FirebaseDatabase());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapEditor(),
    );
  }
}
