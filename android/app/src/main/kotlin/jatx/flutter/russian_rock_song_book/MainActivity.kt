package jatx.flutter.russian_rock_song_book

import android.net.Uri
import androidx.annotation.NonNull
import androidx.activity.result.contract.ActivityResultContracts
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.FileNotFoundException
import java.util.Scanner

class MainActivity: FlutterFragmentActivity() {

    private var theResult: MethodChannel.Result? = null

    private val openDirResultLauncher = registerForActivityResult(
        ActivityResultContracts.OpenDocumentTree()
    ) { uri ->
        uri?.let {
            val pickedDir = DocumentFile.fromTreeUri(this, it)
            pickedDir?.let {
                if (!pickedDir.exists()) {

                } else if (!pickedDir.isDirectory) {

                } else {
                    val files = pickedDir.listFiles()
                    val txtFileList = arrayListOf<DocumentFile>()
                    files.forEach { file ->
                        if (file.exists() && file.isFile && (file.name?.endsWith(".txt") == true)) {
                            txtFileList.add(file)
                        }
                    }
                    val artist = (pickedDir.name ?: "").trim { it <= ' ' }
                    val strings = arrayListOf(artist)
                    txtFileList.forEach { file ->
                        try {
                            val sc = Scanner(contentResolver.openInputStream(file.uri))
                            val text = sc.useDelimiter("\\A").next()
                            val title = file.name?.replace("\\.txt$".toRegex(), "")?.trim() ?: ""
                            strings.add(title)
                            strings.add(text)
                        } catch (e: FileNotFoundException) {
                            e.printStackTrace()
                            val fileName = file.name ?: ""
                        }
                    }
                    theResult?.success(strings)
                }
            }
        }
    }

    private val CHANNEL = "jatx.flutter.russian_rock_song_book/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method == "getDeviceModel") {
                    theResult = result
                    openDirResultLauncher.launch(
                        Uri.fromFile(
                            getExternalFilesDir(null)
                        ))
                } else {
                    // if called undefined method
                    result.notImplemented()
                }
            }
    }
}