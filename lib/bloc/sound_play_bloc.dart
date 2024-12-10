import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SoundPlayBloc extends Bloc<SoundPlayEvent, SoundPlayState?> {
  SoundPlayBloc() : super(null) {
    on<SoundPlayStartedEvent>((event, emit) {
      _player = AudioPlayer();
      _player?.play(BytesSource(event.data, mimeType: 'audio/wav'));
    });

    on<SoundPlayStoppedEvent>((_, __) {
      _player?.stop();
    });
  }

  AudioPlayer? _player;
}

abstract interface class SoundPlayEvent {}

class SoundPlayStartedEvent implements SoundPlayEvent {
  SoundPlayStartedEvent(this.data);

  final Uint8List data;
}

class SoundPlayStoppedEvent implements SoundPlayEvent {
  SoundPlayStoppedEvent();
}

class SoundPlayState {}
