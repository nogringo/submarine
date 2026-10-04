package ovh.uid.submarine

import android.content.ClipData
import android.content.ClipboardManager
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth shows its prompt in a fragment.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "submarine/clipboard")
            .setMethodCallHandler { call, result ->
                if (call.method == "copySensitive") {
                    copySensitive(call.arguments as String)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    /** Copies [text], hidden from the preview Android shows of a copy. */
    private fun copySensitive(text: String) {
        val clip = ClipData.newPlainText(null, text)
        // ClipDescription.EXTRA_IS_SENSITIVE, spelled out for Android 12 and below.
        clip.description.extras = PersistableBundle().apply {
            putBoolean("android.content.extra.IS_SENSITIVE", true)
        }
        getSystemService(ClipboardManager::class.java).setPrimaryClip(clip)
    }
}
