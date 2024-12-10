import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sound_recorder/bloc/sound_play_bloc.dart';
import 'package:sound_recorder/bloc/sound_upload_bloc.dart';

class SoundProceedPage extends StatelessWidget {
  const SoundProceedPage({super.key, required this.data});

  final Uint8List data;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SoundUploadBloc()),
          BlocProvider(create: (_) => SoundPlayBloc()),
        ],
        child: _SoundProceedPage(data),
      );
}

class _SoundProceedPage extends StatefulWidget {
  const _SoundProceedPage(this.data);

  final Uint8List data;

  @override
  State<_SoundProceedPage> createState() => _SoundProceedPageState();
}

class _SoundProceedPageState extends State<_SoundProceedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<SoundUploadBloc>().add(SoundUploadStartedEvent(widget.data)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SoundUploadBloc, SoundUploadState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${state.error}')));
        }

        if (!state.isLoading && state.data != null) {
          context.read<SoundPlayBloc>().add(SoundPlayStartedEvent(state.data!));
        }
      },
      builder: (context, state) => Scaffold(
        body: Center(
          child: state.isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
                    const Gap(20),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/record'),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Record Again'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
