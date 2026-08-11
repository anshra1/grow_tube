class PipState {
  const PipState({
    this.isSupported = false,
    this.isInPipMode = false,
    this.isEnabled = true,
    this.activeVideoId,
    this.activeVideoTabIndex,
  });

  final bool isSupported;
  final bool isInPipMode;
  final bool isEnabled;
  final int? activeVideoId;
  final int? activeVideoTabIndex;

  PipState copyWith({
    bool? isSupported,
    bool? isInPipMode,
    bool? isEnabled,
    int? activeVideoId,
    int? activeVideoTabIndex,
  }) {
    return PipState(
      isSupported: isSupported ?? this.isSupported,
      isInPipMode: isInPipMode ?? this.isInPipMode,
      isEnabled: isEnabled ?? this.isEnabled,
      activeVideoId: activeVideoId ?? this.activeVideoId,
      activeVideoTabIndex: activeVideoTabIndex ?? this.activeVideoTabIndex,
    );
  }
}
