package ovh.uid.submarine

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth shows its prompt in a fragment.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
