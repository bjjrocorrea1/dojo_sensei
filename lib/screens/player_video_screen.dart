import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class PlayerVideoScreen extends StatefulWidget {
  final String caminhoArquivo;
  final String titulo;

  const PlayerVideoScreen({super.key, required this.caminhoArquivo, required this.titulo});

  @override
  State<PlayerVideoScreen> createState() => _PlayerVideoScreenState();
}

class _PlayerVideoScreenState extends State<PlayerVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Se for um arquivo local do celular/PC
    _controller = VideoPlayerController.file(File(widget.caminhoArquivo))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}