import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

class SoundUploadBloc extends Bloc<SoundUploadEvent, SoundUploadState> {
  SoundUploadBloc() : super(const SoundUploadState()) {
    on<SoundUploadStartedEvent>((event, emit) async {
      emit(const SoundUploadState.loading());

      LocationPermission? geoPermission;
      Position? position;
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(const SoundUploadState.error('Location service is disabled'));
      } else {
        geoPermission = await Geolocator.checkPermission();
        if (geoPermission == LocationPermission.denied) {
          geoPermission = await Geolocator.requestPermission();
          if (geoPermission == LocationPermission.denied) {
            emit(const SoundUploadState.error('Permission denied'));
          }
        } else if (geoPermission == LocationPermission.deniedForever) {
          emit(const SoundUploadState.error('Permission denied forever'));
        }

        if (geoPermission == LocationPermission.always || geoPermission == LocationPermission.whileInUse) {
          try {
            position = await Geolocator.getCurrentPosition();
          } on TimeoutException {
            emit(const SoundUploadState.error('Failed to get location'));
          } on LocationServiceDisabledException {
            emit(const SoundUploadState.error('Location service is disabled'));
          }
        }
      }

      final request = MultipartRequest('POST', Uri.parse('http://140.115.54.46:5000/'));
      request.files.add(MultipartFile.fromBytes('audio', event.data, filename: 'audio.wav'));
      if (position != null) {
        request.fields['latitude'] = position.latitude.toString();
        request.fields['longitude'] = position.longitude.toString();
      }
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
