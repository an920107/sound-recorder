import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sound_recorder/bloc/sound_record_bloc.dart';

class SoundRecordPage extends StatelessWidget {
  const SoundRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => SoundRecordBloc(), child: const _SoundRecordPage());
  }
}

class _SoundRecordPage extends StatefulWidget {
  const _SoundRecordPage();

  @override
  State<_SoundRecordPage> createState() => _SoundRecordPageState();
}

class _SoundRecordPageState extends State<_SoundRecordPage> {
  Widget get _recordButton => ElevatedButton(
        onPressed: () {
          context.read<SoundRecordBloc>().add(SoundRecordStartedEvent());
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        child: Ink(
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.shade400),
          child: SizedBox.square(
            dimension: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ClipOval(child: Container(width: 30, height: 30, color: Colors.red.shade100))],
            ),
          ),
        ),
      );

  Widget get _stopButton => ElevatedButton(
        onPressed: () => context.read<SoundRecordBloc>().add(SoundRecordStopedEvent()),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Ink(
          decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(4)),
          child: const SizedBox.square(dimension: 72),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SoundRecordBloc, SoundRecordState>(
      listener: (_, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${state.error}')));
          return;
        }

        if (!state.isRecording && state.data != null) {
          context.go('/proceed', extra: state.data);
        }
      },
      builder: (_, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              state.isRecording ? _stopButton : _recordButton,
            ],
          ),
        ),
      ),
    );
  }
}
