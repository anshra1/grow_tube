Implementation Plan - Youtube Style Landscape
Implementation Plan - Youtube Style Landscape
The goal is to implement "YouTube-style" orientation behavior.

Feature Specification
Here is the complete list of features we will implement:

Smart Auto-Rotate

Action: Rotate device to horizontal (landscape).
Result: Player expands to Fullscreen Landscape automatically.
Reverse: Rotate device back to vertical (portrait) -> Player contracts to normal size.
Constraint: Respects the system's "Auto-rotate" toggle.
Manual Fullscreen Button

Action: User taps the Fullscreen icon [ ] on the video overlay.
Result:
If in Portrait: Forces the screen to rotate to Landscape and enter Fullscreen.
If in Landscape: Forces the screen to rotate back to Portrait and exit Fullscreen.
Back Button Logic (Android)

Action: User presses the physical/gesture Back button.
Result:
IF in Fullscreen: Exits Fullscreen Mode -> Returns to Portrait. (Does NOT close the page).
IF in Portrait: Normal navigation (pop page or minimize app).
Immersive Mode

Action: Entering Fullscreen.
Result: Hides the System Status Bar (Time, Battery) and Navigation Bar (Home/Back) for a full edge-to-edge experience. Tapping the screen brings them back temporarily with the playback controls.
Seamless Transition

Result: The video playback continues smoothly without pausing/buffering during the rotation.
User Review Required
IMPORTANT

I will be stripping the custom listener logic from 
main.dart
 and moving the orientation management into 
MxPlayerScaffold
. This makes the player self-contained and reusable.

Proposed Changes
Package: mx_youtube_player
[MODIFY] 
mx_player_scaffold.dart
Add PopScope: Intercept back button when in fullscreen to exit fullscreen instead of popping the page.
Add Orientation Listener: Use 
didChangeMetrics
 or OrientationBuilder to detect device rotation.
If rotated to Landscape -> Enter Fullscreen mode (Immersive Sticky).
If rotated to Portrait -> Exit Fullscreen mode (EdgeToEdge).
Update 
initState
: Allow all orientations (DeviceOrientation.values) by default to support auto-rotation.
Sync Controller: Ensure YoutubePlayerController state matches the device orientation.
[MODIFY] 
mx_player_overlay.dart
Ensure the fullscreen button triggers the logic that 
MxPlayerScaffold
 listens to (via controller.toggleFullScreen).
Application: skill_tube
[MODIFY] 
main.dart
Remove the manual _controller.setFullScreenListener logic that forces orientations.
Rely on 
MxPlayerScaffold
 to handle it internally.
Verification Plan
Manual Verification
Auto-Rotate:
Run app on device/emulator.
Rotate device to Landscape -> Player should expand, UI bars hide.
Rotate device to Portrait -> Player should shrink, UI bars show.
Manual Toggle:
Tap Fullscreen icon -> Forces Landscape.
Tap Exit Fullscreen icon -> Forces Portrait.
Back Button:
Enter Fullscreen.
Tap Android Back button -> Should return to Portrait (not exit app).