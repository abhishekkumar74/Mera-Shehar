package com.merashehar.roz

import android.content.ContentValues
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mera_shehar/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareToWhatsApp" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }
                    val status = handleShareToWhatsApp(path)
                    result.success(status)
                }
                "saveToGallery" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }
                    val status = handleSaveToGallery(path)
                    result.success(status)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun handleShareToWhatsApp(filePath: String): String {
        val file = File(filePath)
        if (!file.exists()) return "file_not_found"

        val authority = "${context.packageName}.fileprovider"
        val contentUri: Uri = FileProvider.getUriForFile(context, authority, file)

        fun tryIntent(packageName: String): Boolean {
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "image/png"
                putExtra(Intent.EXTRA_STREAM, contentUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                setPackage(packageName)
            }
            return try {
                startActivity(intent)
                true
            } catch (e: ActivityNotFoundException) {
                false
            }
        }

        if (tryIntent("com.whatsapp")) return "ok"
        if (tryIntent("com.whatsapp.w4b")) return "ok"

        return "not_installed"
    }

    private fun handleSaveToGallery(filePath: String): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return "unsupported"
        }

        val file = File(filePath)
        if (!file.exists()) return "file_not_found"

        try {
            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, "MeraShehar_${System.currentTimeMillis()}.png")
                put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/Mera Shehar")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }

            val resolver = context.contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                ?: return "error"

            resolver.openOutputStream(uri).use { outputStream ->
                FileInputStream(file).use { inputStream ->
                    inputStream.copyTo(outputStream!!)
                }
            }

            contentValues.clear()
            contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)

            return "ok"
        } catch (e: Exception) {
            return "error"
        }
    }
}
