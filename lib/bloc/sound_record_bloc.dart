import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SoundRecordBloc extends Bloc<SoundRecordEvent, SoundRecordState> {
  SoundRecordBloc() : super(const SoundRecordState()) {
    on<SoundRecordStartedEvent>((_, emit) async {
      _recorder = AudioRecorder();
      if (!await _recorder!.hasPermission()) {
        emit(const SoundRecordState.error('Permission denied'));
        return;
      }

      final path = join((await getTemporaryDirectory()).absolute.path, 'audio.wav');
      await _recorder?.start(
        const RecordConfig(androidConfig: AndroidRecordConfig(audioSource: AndroidAudioSource.mic)),
        path: path,
      );

      emit(const SoundRecordState.recording());
    });

    on<SoundRecordStopedEvent>((_, emit) async {
      final path = await _recorder?.stop();
      await _recorder?.dispose();
      _recorder = null;

      if (path == null) {
        emit(const SoundRecordState.error('Failed to stop recording'));
        return;
      }

      emit(SoundRecordState.success(await File(path).readAsBytes()));
    });
  }

  AudioRecorder? _recorder;
}

abstract interface class SoundRecordEvent {}

class SoundRecordStartedEvent implements SoundRecordEvent {
  SoundRecordStartedEvent();
}

class SoundRecordStopedEvent implements SoundRecordEvent {
  SoundRecordStopedEvent();
}

class SoundRecordState extends Equatable {
  const SoundRecordState()
      : isRecording = false,
        data = null,
        error = null;

  const SoundRecordState.recording()
      : isRecording = true,
        data = null,
        error = null;

  const SoundRecordState.success(Uint8List this.data)
      : isRecording = false,
        error = null;

  const SoundRecordState.error(Object this.error)
      : isRecording = false,
        data = null;

  final bool isRecording;
  final Uint8List? data;
  final Object? error;

  @override
  List<Object?> get props => [isRecording, data, error];
}
