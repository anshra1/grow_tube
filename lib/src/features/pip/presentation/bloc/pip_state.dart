class PipState {
  const PipState({
    this.isSupported = false,
    this.isInPipMode = false,
  });

  final bool isSupported;
  final bool isInPipMode;

  PipState copyWith({
    bool? isSupported,
    bool? isInPipMode,
  }) {
    return PipState(
      isSupported: isSupported ?? this.isSupported,
      isInPipMode: isInPipMode ?? this.isInPipMode,
    );
  }
}
