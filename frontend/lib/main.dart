import 'package:flutter/material.dart';

import 'src/app/vidivideo_app.dart';

import 'package:video_player_media_kit/video_player_media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  VideoPlayerMediaKit.ensureInitialized(
    windows: true,
  );

  runApp(const VidiVideoApp());
}
