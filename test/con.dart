import 'dart:async';
import 'dart:isolate';

// This function will run on a separate Background Isolate.
// Important: It must be a top-level function or static method.
int doHeavyComputation(int limit) {
  print('➔ [Background Isolate] Starting heavy calculation...');
  int sum = 0;
  for (int i = 0; i < limit; i++) {
    // Just a loop to consume CPU time
    sum += 1;
  }
  print('➔ [Background Isolate] Calculation finished!');
  return sum;
}

void main() async {
  print('▶ [Main Thread] App started.');

  // 1. Let's start a periodic timer on the Main Thread.
  // This simulates an active UI. If the Main Thread gets blocked, this will freeze.
  Timer uiTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    print('▶ [Main Thread] UI is responsive... (tick ${timer.tick})');
  });

  print('▶ [Main Thread] Spawning a Background Isolate...');

  // 2. Spawn the Isolate.
  // Even though we 'await' the result, the Main Thread's event loop is NOT blocked.
  // The timer above will keep running smoothly.
  int result = await Isolate.run(() => doHeavyComputation(4000000000));

  print('▶ [Main Thread] Received result from Isolate: $result');

  // 3. Clean up
  uiTimer.cancel();
  print('▶ [Main Thread] App exiting safely.');
}
