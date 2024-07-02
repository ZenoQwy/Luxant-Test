import 'package:permission_handler/permission_handler.dart';
import 'package:test/GoogleServices/googlePhotos.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:io';


class AudioRecorderPage extends StatefulWidget {
  const AudioRecorderPage({super.key});

  @override
  State<AudioRecorderPage> createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  FlutterSoundRecorder? _recorder;
  AudioPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _audioPlayer = AudioPlayer();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await _requestPermissions();
  }


  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/audio.aac';
    await _recorder!.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playAudio() async {
    if (_filePath != null && !_isPlaying) {
      await _audioPlayer!.play(DeviceFileSource(_filePath!));
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      _audioPlayer!.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
        });
      });
    }
  }

  Future<void> _pauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer!.pause();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    }
  }

  Future<void> _stopAudio() async {
    _audioPlayer!.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _audioPlayer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white12,
          title: const Text("Enregister un vocal",
              style: TextStyle(color: Colors.white))),
      backgroundColor: Colors.white12,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 50),
              if (!_isPaused && !_isPlaying)

                // Bouton start / stop playing
                ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          _isRecording ? 'Stop Recording' : 'Start Recording',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        )
                    )
                ),
              if (!_isRecording && _filePath != null) ...[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: _isPlaying ? _pauseAudio : _playAudio,
                        child:
                            Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: _stopAudio,
                        child: const Icon(Icons.stop),
                      )
                  ),
                ]),

                // Bouton pour importation sur Google Drive
                ElevatedButton(
                    onPressed: () {
                      GoogleDriveApiService().upload(File(_filePath!));
                      _stopAudio();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.70,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Importer sur Google Drive",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              "assets/googleDrive.png",
                              height: 30,
                            )
                          ]),
                    )
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
