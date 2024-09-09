import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_teachable_machine_app/detectScreen.dart';

List<CameraDescription> cameras = []; //0  behind   1 front

// dart Layer <=> flutter engine
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Detectscreen(),
    );
  }
}
