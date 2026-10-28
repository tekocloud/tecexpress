package cloud.teko.tecexpress

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import android.view.DragEvent
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.OutputStream
import java.util.UUID
import java.util.Collections
import java.util.concurrent.Executors

/** System file integration; no storage permission or AndroidX dependency. */
class TecexpressPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
    PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context
    private var activity: Activity? = null
    private var binding: ActivityPluginBinding? = null
    private var view: View? = null
    private var pending: MethodChannel.Result? = null
    private var pendingMethod = ""
    private var multiple = false
    private var targets = emptyList<Map<String, Any>>()
    private val owned = Collections.synchronizedSet(mutableSetOf<String>())
    private val outputs = mutableMapOf<String, OutputStream>()
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val requestCode = 0x7465

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "tecexpress/files")
        channel.setMethodCallHandler(this)
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        detach()
        outputs.values.forEach { runCatching { it.close() } }; outputs.clear()
        synchronized(owned) { owned.forEach { File(it).delete() }; owned.clear() }
        worker.shutdown()
    }
    private fun findFlutter(v: View): View? {
        if (v is FlutterView) return v
        if (v is ViewGroup) for (i in 0 until v.childCount) {
            findFlutter(v.getChildAt(i))?.let { return it }
        }
        return null
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding; activity = binding.activity
        binding.addActivityResultListener(this)
        // Engine attachment can precede FlutterActivity.setContentView.
        binding.activity.window.decorView.post {
            if (activity !== binding.activity) return@post
            view = findFlutter(binding.activity.window.decorView)
            view?.setOnDragListener { _, event -> onDrag(event) }
        }
    }
    private fun detach() {
        binding?.removeActivityResultListener(this)
        view?.setOnDragListener(null); view = null
        binding = null; activity = null
        pending?.error("detached", "Activity detached", null); pending = null
    }
    override fun onDetachedFromActivityForConfigChanges() { detach() }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { onAttachedToActivity(binding) }
    override fun onDetachedFromActivity() { detach() }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "targets" -> { targets = call.arguments as? List<Map<String, Any>> ?: emptyList(); result.success(null) }
                "pick", "beginSave" -> {
                    val host = activity ?: throw IllegalStateException("No attached activity")
                    if (pending != null) { result.error("busy", "Another file dialog is open", null); return }
                    val intent = if (call.method == "pick") {
                        multiple = call.argument<Boolean>("multiple") == true
                        Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE); type = "*/*"
                            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiple)
                        }
                    } else Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE); type = "application/octet-stream"
                        putExtra(Intent.EXTRA_TITLE, call.argument<String>("name"))
                    }
                    pending = result; pendingMethod = call.method
                    try { host.startActivityForResult(intent, requestCode) }
                    catch (e: Exception) { pending = null; throw e }
                }
                "writeSave" -> {
                    val out = outputs[call.argument<String>("token")] ?: throw IllegalStateException("Unknown save")
                    out.write(call.argument<ByteArray>("bytes")!!); result.success(null)
                }
                "finishSave", "abortSave" -> {
                    outputs.remove(call.argument<String>("token"))?.close(); result.success(null)
                }
                "release" -> {
                    val path = call.argument<String>("path")!!
                    if (owned.remove(path)) File(path).delete()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) { result.error("file_error", e.message, null) }
    }

    private fun copyUri(uri: Uri): Map<String, Any?> {
        if (context.contentResolver.getType(uri) == "vnd.android.document/directory") {
            throw IllegalArgumentException("Directory drops are not supported")
        }
        var name = "file"
        context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use {
            if (it.moveToFirst()) name = it.getString(0) ?: name
        }
        name = name.substringAfterLast('/').substringAfterLast('\\')
        val file = File.createTempFile("tecexpress-", ".tmp", context.cacheDir)
        try {
            context.contentResolver.openInputStream(uri)?.use { input -> file.outputStream().use { input.copyTo(it, 65536) } }
                ?: throw IllegalStateException("Cannot read selected document")
            synchronized(owned) { owned.add(file.path) }
            return mapOf("path" to file.path, "name" to name, "mimeType" to context.contentResolver.getType(uri), "owned" to true)
        } catch (e: Exception) { file.delete(); throw e }
    }
    override fun onActivityResult(request: Int, code: Int, data: Intent?): Boolean {
        if (request != requestCode) return false
        val result = pending ?: return true
        pending = null
        if (code != Activity.RESULT_OK || data == null) {
            result.success(if (pendingMethod == "pick") emptyList<Any>() else null); return true
        }
        if (pendingMethod == "beginSave") {
            try {
                val token = UUID.randomUUID().toString()
                outputs[token] = context.contentResolver.openOutputStream(data.data!!, "wt")!!
                result.success(token)
            } catch (e: Exception) { result.error("save_error", e.message, null) }
        } else {
            val uris = mutableListOf<Uri>()
            data.clipData?.let { clip -> for (i in 0 until clip.itemCount) uris.add(clip.getItemAt(i).uri) }
            if (uris.isEmpty()) data.data?.let { uris.add(it) }
            worker.execute {
                try {
                    val files = (if (multiple) uris else uris.take(1)).map { copyUri(it) }
                    main.post { result.success(files) }
                } catch (e: Exception) { main.post { result.error("read_error", e.message, null) } }
            }
        }
        return true
    }
    private fun onDrag(event: DragEvent): Boolean {
        if (event.action == DragEvent.ACTION_DRAG_STARTED) return targets.isNotEmpty() && event.clipDescription != null
        val density = context.resources.displayMetrics.density
        val x = event.x / density; val y = event.y / density
        val target = targets.lastOrNull { t ->
            x >= (t["left"] as Number).toDouble() && x < (t["right"] as Number).toDouble() &&
            y >= (t["top"] as Number).toDouble() && y < (t["bottom"] as Number).toDouble()
        }
        if (event.action != DragEvent.ACTION_DROP) return target != null
        if (target == null) return false
        val clip = event.clipData ?: return false
        val uris = (0 until clip.itemCount).mapNotNull { clip.getItemAt(it).uri }
        if (uris.isEmpty()) return false
        val permission = if (android.os.Build.VERSION.SDK_INT >= 24) activity?.requestDragAndDropPermissions(event) else null
        worker.execute {
            try {
                val files = uris.map { copyUri(it) }
                main.post { channel.invokeMethod("drop", mapOf("x" to x, "y" to y, "viewId" to target["viewId"], "files" to files)) }
            } catch (e: Exception) {
                main.post { channel.invokeMethod("dropError", mapOf("message" to (e.message ?: "Cannot read dropped files"))) }
            } finally { permission?.release() }
        }
        return true
    }
}
