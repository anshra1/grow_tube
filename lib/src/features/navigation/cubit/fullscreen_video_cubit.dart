import 'package:flutter_bloc/flutter_bloc.dart';

/// Coordinates shell chrome while a video is displayed fullscreen.
class FullscreenVideoCubit extends Cubit<bool> {
  FullscreenVideoCubit() : super(false);

  void enterFullscreen() => emit(true);

  void exitFullscreen() => emit(false);
}
