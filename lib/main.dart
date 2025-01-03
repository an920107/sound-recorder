import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:sound_recorder/page/sound_proceed_page.dart';
import 'package:sound_recorder/page/sound_record_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocationPermission? geoPermission;
  geoPermission = await Geolocator.checkPermission();
  if (geoPermission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sound Recorder',
      theme: ThemeData.dark(),
      routerConfig: GoRouter(
        initialLocation: '/record',
        routes: [
          GoRoute(path: '/record', builder: (_, __) => const SoundRecordPage()),
          GoRoute(path: '/proceed', builder: (_, state) => SoundProceedPage(data: state.extra as Uint8List))
        ],
      ),
    );
  }
}
