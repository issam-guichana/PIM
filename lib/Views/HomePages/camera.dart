import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

Future<void> cameraScreen() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp(this.cameras, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ObjectDetectionScreen(cameras),
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ObjectDetectionScreen(this.cameras, {super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? _controller;
  bool _isDetecting = false;
  List<dynamic> _detections = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
      try {
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
          _startDetection(); 
        }
      } catch (e) {
        print("Erreur d'initialisation de la caméra: $e");
      }
    }
  }

  @override
  void dispose() {
    _isDetecting = false; 
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startDetection() async {
    if (_isDetecting || _controller == null || !_controller!.value.isInitialized) return;

    _isDetecting = true;

    while (_isDetecting) {
      try {
        final image = await _controller!.takePicture();
        final imageFile = File(image.path);

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://172.20.10.6:5001/detect'), 
        );
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (mounted) {
          setState(() {
            _detections = json.decode(responseData)['detections'];
          });
        }

        
        await imageFile.delete();
      } catch (e) {
        print("Erreur pendant la détection : $e");
      }

      await Future.delayed(Duration(seconds: 2));
    }
  }

  @override
Widget build(BuildContext context) {
  if (_controller == null || !_controller!.value.isInitialized) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détection en temps réel')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(title: const Text('Détection en temps réel')),
    body: Stack(
      children: [
        // Caméra en fond
        CameraPreview(_controller!),

        // Superposition des cadres des objets détectés
        ..._detections.map((detection) {
          var box = detection['box']; // [x1, y1, x2, y2]
          double left = box[0].toDouble();
          double top = box[1].toDouble();
          double width = (box[2] - box[0]).toDouble();
          double height = (box[3] - box[1]).toDouble();

          return Positioned(
            left: left,
            top: top,
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3), // Bordure rouge pour chaque objet détecté
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.red,
                  child: Text(
                    "${detection['class']} (${(detection['confidence'] * 100).toStringAsFixed(1)}%)",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    ),

    floatingActionButton: FloatingActionButton(
      onPressed: () {
        setState(() {
          _isDetecting = !_isDetecting;
        });
        if (_isDetecting) {
          _startDetection();
        }
      },
      child: Icon(_isDetecting ? Icons.stop : Icons.camera),
    ),
  );
}



}
