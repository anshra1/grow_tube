package com.ansh.levelup_tube

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
    }

    private val pipChannelName = "com.ansh.levelup_tube/pip"
    private var methodChannel: MethodChannel? = null
    private var canAutoEnterPip = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannelName)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPipMode" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val width = call.argument<Int>("width") ?: 16
                        val height = call.argument<Int>("height") ?: 9
                        val aspectRatio = Rational(width, height)

                        val params = PictureInPictureParams.Builder()
                            .setAspectRatio(aspectRatio)
                            .build()

                        val entered = enterPictureInPictureMode(params)
                        result.success(entered)
                    } else {
                        result.error("UNSUPPORTED", "PiP requires Android 8.0 (API 26) or above", null)
                    }
                }
                "isPipSupported" -> {
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                }
                "isPipActive" -> {
                    result.success(isInPictureInPictureMode)
                }
                "setAutoEnterPip" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    canAutoEnterPip = enabled
                    
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val params = PictureInPictureParams.Builder()
                            .setAutoEnterEnabled(enabled)
                            .setAspectRatio(Rational(16, 9))
                            .build()
                        setPictureInPictureParams(params)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (canAutoEnterPip && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Android 12+ (API 31+) uses setAutoEnterEnabled(true) which handles this automatically.
            // Calling enterPictureInPictureMode here on API 31+ causes a glitch/white screen.
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(16, 9))
                    .build()
                enterPictureInPictureMode(params)
            }
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        // Notify Flutter side about PiP state changes
        methodChannel?.invokeMethod("onPipChanged", isInPictureInPictureMode)
    }

    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && isInPictureInPictureMode) {
            // Keep the Flutter engine running to prevent the video from pausing
            flutterEngine?.lifecycleChannel?.appIsResumed()
        }
    }
}
