import 'package:test/GoogleServices/googlePhotos.dart';
import 'package:test/pages/audioRecorderPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:test/pages/cameraPage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Ouvre l'explorateur de fichier afin de procéder à l'importation sur googleDrive
  pickAndUpFIle() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      await GoogleDriveApiService().upload(file);
    }
  }

  // Permet d'ouvrir le menu de la caméra afin de prendre une photo / une vidéo
  takePictureOrVideo() async {
    // Initialisation des caméras et détection de celles disponibles
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();

    // Push vers la page qui disposera la caméra
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builder) => CameraScreen(cameras: cameras),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          // Bouton pour importation de fichier
          ElevatedButton(
              onPressed: () {
                pickAndUpFIle();
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.white12))),
                  backgroundColor: const MaterialStatePropertyAll<Color>(
                    Colors.transparent,
                  )
              ),
              child: const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder, size: 80),
                        Padding(
                            padding: EdgeInsets.only(top: 21),
                            child: Text("Importer depuis vos fichiers ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.white))),
                      ])
              )
          ),

          // Bouton pour caméra
          ElevatedButton(
              onPressed: () {
                takePictureOrVideo();
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.white12))),
                  backgroundColor: const MaterialStatePropertyAll<Color>(
                    Colors.transparent,
                  )),
              child: const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 80),
                        Padding(
                            padding: EdgeInsets.only(top: 21),
                            child: Text("Importez depuis la caméra   ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.white))),
                      ])
              )
          ),

          // Bouton pour audio
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (builder) => const AudioRecorderPage(),
                  ),
                );
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.white12))),
                  backgroundColor: const MaterialStatePropertyAll<Color>(
                    Colors.transparent,
                  )),
              child: const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_rounded, size: 80),
                        Padding(
                            padding: EdgeInsets.only(top: 21),
                            child: Text("Importez depuis le magnéto",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.white)
                            )
                        ),
                      ])
              )
          ),
        ]),
      ),
    );
  }
}
