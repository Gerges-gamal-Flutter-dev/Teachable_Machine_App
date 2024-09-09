// ignore_for_file: file_names
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_teachable_machine_app/main.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class Detectscreen extends StatefulWidget {
  const Detectscreen({super.key});

  @override
  State<Detectscreen> createState() => _DetectscreenState();
}

class _DetectscreenState extends State<Detectscreen> {
  String output = "";
  double confidence = 0;
  CameraController? cameraController;

  // Load camera
  loadCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController!.startImageStream((CameraImage image) {
          runModel(image);
        });
      });
    });
  }

  // Load model
  lodelModel() async {
    await Tflite.loadModel(
      model: "assets/converted_tflite/model_unquant.tflite",
      labels: "assets/converted_tflite/labels.txt",
    );
  }

  // Run model
  runModel(CameraImage img) async {
    dynamic recognitions = await Tflite.runModelOnFrame(
      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: img.height,
      imageWidth: img.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );

    for (var element in recognitions) {
      setState(() {
        output = element['label'];
        confidence = element['confidence'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
    lodelModel();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Object Detection"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 4,
            child: cameraController == null ||
                    !cameraController!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(cameraController!),
          ),
          // Detection result
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.deepPurple[50],
              child: Center(
                child: Text(
                  "$output         ${(confidence * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       output = "";
      //     });
      //   },
      //   backgroundColor: Colors.deepPurple,
      //   child: const Icon(Icons.camera_alt),
      // ),
    );
  }
}
