import 'package:path_provider/path_provider.dart';
import 'package:test/pages/filePreview.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({required this.cameras, super.key});
  final List<CameraDescription> cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Gérer la prévisualisation, prendre des photos...
  late CameraController _cameraController;

  // Savoir quand la caméra est initialisée et prête à être utilisée
  late Future<void> cameraValue;

  // Caméra actuelle utilisée (avant ou arrière).
  late CameraDescription currentCamera;

  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    currentCamera = widget.cameras[0]; // Caméra arrière de ce fait
    _cameraController = CameraController(
      currentCamera,
      ResolutionPreset.high
    );
    cameraValue = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // Permet de changer entre caméra arrière et caméra avant
  void switchCamera() {
    if(isRecording == false){
    setState(() {
      currentCamera = (currentCamera == widget.cameras[0])
          ? widget.cameras[1]
          : widget.cameras[0];
      _cameraController = CameraController(
        currentCamera,
        ResolutionPreset.high,
      );
      cameraValue = _cameraController.initialize();
    });
    }
  }

  void takePicture() async{
    if(isRecording == false){
      try {
        await cameraValue;
        await Future.delayed(Duration(seconds: 1));
        final image = await _cameraController.takePicture();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => FilePreview(file: image.path),
        ));
      } catch (e) {
        print(e);
      }
    }
  }

  void startVideoRecording() async {
    try {
      await cameraValue;
      if (!_cameraController.value.isRecordingVideo) {
        setState(() {
          isRecording = true;
        });
        await _cameraController.startVideoRecording();
      }
    } catch (e) {
      print(e);
    }
  }

  void stopVideoRecording() async {
    try {
      if (_cameraController.value.isRecordingVideo) {
        XFile videoFile = await _cameraController.stopVideoRecording();

        // Copier le fichier vidéo temporaire vers un emplacement permanent
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String finalVideoPath = '${appDir.path}/video.mp4';
        await File(videoFile.path).copy(finalVideoPath);

        setState(() {
          isRecording = false;
        });

        // Passer le chemin du fichier final à FilePreview
        Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => FilePreview(file: finalVideoPath),
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white12,title: Text("Prendre une photo | une vidéo",style: TextStyle(color: Colors.white,),)),
      backgroundColor: Colors.white12,
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        child: FutureBuilder<void>(
          future: cameraValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_cameraController);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 30.0,
              color: Colors.white,
              icon: new Icon(Icons.arrow_back), onPressed: () { Navigator.of(context).pop(); },),

            // Bouton pour changer la caméra
            IconButton(
              icon: Icon(Icons.switch_camera),
              iconSize: 30,
              color: Colors.white,
              onPressed:
                switchCamera,
            ),

            // Bouton pour prendre la photo
            IconButton(
              icon: Icon(Icons.camera_alt),
              iconSize: 30,
              color: Colors.white,
              onPressed:
                takePicture,
            ),

            // Bouton pour démarrer/arrêter l'enregistrement vidéo
            IconButton(
              icon: Icon(isRecording ? Icons.stop : Icons.videocam),
              iconSize: 30,
              color: Colors.white,
              onPressed: isRecording ? stopVideoRecording : startVideoRecording,
            ),
          ],
        ),
      ),
    );
  }
}
