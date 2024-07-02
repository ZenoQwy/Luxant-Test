import 'package:video_player/video_player.dart';
import '/GoogleServices/googlePhotos.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FilePreview extends StatefulWidget {
  const FilePreview({required this.file, super.key});
  final String file;

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  late Widget _bodyWidget;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Vérifier si le fichier est une vidéo en vérifiant l'extension
    if (widget.file.endsWith('.mp4')) {
      _bodyWidget = _buildVideoPreview();
    } else {
      _bodyWidget = _buildImagePreview();
    }
  }

  Widget _buildVideoPreview() {
    _controller = VideoPlayerController.file(File(widget.file));
    final _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Démarrer la lecture automatiquement une fois initialisé
      _controller.play();
    });
    // Boucler la vidéo
    _controller.setLooping(true);

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildImagePreview() {
    return Image.file(File(widget.file));
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              iconSize: 40.0,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const Text(
              "Prévisualisation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            IconButton(
              onPressed: () {
                GoogleDriveApiService().upload(File(widget.file));
              },
              icon: Image.asset("assets/googleDrive.png", height: 50),
            ),
          ],
        ),
      ),
    );
  }
}
