import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TapToPlayFlower extends StatefulWidget {
  const TapToPlayFlower({super.key});

  @override
  State<TapToPlayFlower> createState() => _TapToPlayFlowerState();
}

class _TapToPlayFlowerState extends State<TapToPlayFlower> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/tulips.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..addListener(_videoListener);
  }

  void _videoListener() {
    // When video finishes
    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying) {
      _controller.seekTo(Duration.zero);
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _playVideo() {
    if (_isPlaying) return; // 🚫 block multiple taps

    setState(() {
      _isPlaying = true;
    });

    _controller
      ..seekTo(Duration.zero)
      ..play();
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        width: 105,
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: _playVideo,
      child: SizedBox(
        width: 105,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // optional rounded corners
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio, // MATCH video
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
