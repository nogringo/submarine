package ovh.uid.submarine

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth shows its prompt in a fragment.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Blocked from the first frame, until the settings read in Dart allow it.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        // Keeps the app switcher preview hidden once screen capture is allowed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) setRecentsScreenshotEnabled(false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "submarine/screen_capture")
            .setMethodCallHandler { call, result ->
                if (call.method == "allow") {
                    if (call.arguments as Boolean) {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "submarine/clipboard")
            .setMethodCallHandler { call, result ->
                if (call.method == "copy") {
                    AppClipboard.copy(
                        applicationContext,
                        call.argument<String>("text")!!,
                        call.argument<Boolean>("sensitive")!!,
                        call.argument<Number>("clearAfter")?.toLong(),
                    )
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
