import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class SoundUploadBloc extends Bloc<SoundUploadEvent, SoundUploadState> {
  SoundUploadBloc() : super(const SoundUploadState()) {
    on<SoundUploadStartedEvent>((event, emit) async {
      emit(const SoundUploadState.loading());

      final request = MultipartRequest('POST', Uri.parse('http://140.115.54.46:5000/'));
      request.files.add(MultipartFile.fromBytes('audio', event.data, filename: 'audio.wav'));
      final streamResponse = await request.send();
      final response = await Response.fromStream(streamResponse);

      if (response.statusCode != 200) {
        emit(const SoundUploadState.error('Failed to upload sound'));
        return;
      }

      emit(SoundUploadState.success(response.bodyBytes));
    });
  }
}

abstract interface class SoundUploadEvent {}

class SoundUploadStartedEvent implements SoundUploadEvent {
  SoundUploadStartedEvent(this.data);

  final Uint8List data;
}

class SoundUploadState extends Equatable {
  const SoundUploadState()
      : isLoading = false,
        data = null,
        error = null;

  const SoundUploadState.loading()
      : isLoading = true,
        data = null,
        error = null;

  const SoundUploadState.success(Uint8List this.data)
      : isLoading = false,
        error = null;

  const SoundUploadState.error(Object this.error)
      : isLoading = false,
        data = null;

  final bool isLoading;
  final Uint8List? data;
  final Object? error;

  @override
  List<Object?> get props => [isLoading];
}
