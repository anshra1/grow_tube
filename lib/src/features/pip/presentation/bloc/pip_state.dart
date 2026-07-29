class PipState {
  const PipState({
    this.isSupported = false,
    this.isInPipMode = false,
    this.isEnabled = true,
  });

  final bool isSupported;
  final bool isInPipMode;
  final bool isEnabled;

  PipState copyWith({
    bool? isSupported,
    bool? isInPipMode,
    bool? isEnabled,
  }) {
    return PipState(
      isSupported: isSupported ?? this.isSupported,
      isInPipMode: isInPipMode ?? this.isInPipMode,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
