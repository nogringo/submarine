package ovh.uid.submarine

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ClipData
import android.content.ClipboardManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle

object AppClipboard {
    private const val CLEAR_JOB_ID = 1
    private val handler = Handler(Looper.getMainLooper())

    /**
     * Copies [text], hidden from the preview Android shows of a copy if [sensitive], and clears it
     * after [clearAfter] milliseconds unless the app copies again first.
     */
    fun copy(context: Context, text: String, sensitive: Boolean, clearAfter: Long?) {
        val clip = ClipData.newPlainText(null, text)
        if (sensitive) {
            // ClipDescription.EXTRA_IS_SENSITIVE, spelled out for Android 12 and below.
            clip.description.extras = PersistableBundle().apply {
                putBoolean("android.content.extra.IS_SENSITIVE", true)
            }
        }
        context.getSystemService(ClipboardManager::class.java).setPrimaryClip(clip)
        cancelClear(context)
        if (clearAfter == null) return
        // The handler stops once Android freezes the app in the background, where the job wakes
        // it up, though the battery saver may hold the job back.
        handler.postDelayed({ clear(context) }, clearAfter)
        val job = JobInfo.Builder(CLEAR_JOB_ID, ComponentName(context, ClearClipboardJob::class.java))
            .setMinimumLatency(clearAfter)
            .build()
        context.getSystemService(JobScheduler::class.java).schedule(job)
    }

    fun clear(context: Context) {
        cancelClear(context)
        val clipboard = context.getSystemService(ClipboardManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            clipboard.clearPrimaryClip()
        } else {
            clipboard.setPrimaryClip(ClipData.newPlainText(null, ""))
        }
    }

    private fun cancelClear(context: Context) {
        handler.removeCallbacksAndMessages(null)
        context.getSystemService(JobScheduler::class.java).cancel(CLEAR_JOB_ID)
    }
}

class ClearClipboardJob : JobService() {
    override fun onStartJob(params: JobParameters): Boolean {
        AppClipboard.clear(this)
        return false
    }

    override fun onStopJob(params: JobParameters) = false
}
