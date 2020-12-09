package com.example.filepicker

import androidx.annotation.NonNull;
import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import android.net.Uri
import android.os.Bundle
import android.os.AsyncTask
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.*
import android.os.Environment
import android.provider.MediaStore
import android.database.Cursor

/** FilepickerPlugin */
public class FilepickerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var resultCb:MethodChannel.Result?=null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "filepicker")
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "filepicker")
      channel.setMethodCallHandler(FilepickerPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if(call.method == "openFilePicker"){
      val intent = Intent()
              .setType("*/*")
              .setAction(Intent.ACTION_GET_CONTENT)
      resultCb = result
      startActivityForResult(Intent.createChooser(intent, "Select a file"), 111)
    }
    else {
      result.notImplemented()
    }
  }

  private fun getPath(uri:Uri) : String {

    var  path:String? = null
    val projection = arrayOf( MediaStore.Files.FileColumns.DATA)
    var cursor:Cursor = getContentResolver().query(uri, projection, null, null, null)

    if(cursor == null){
      path = uri.getPath()
    }
    else{
      cursor.moveToFirst()
      var column_index = cursor.getColumnIndexOrThrow(projection[0])
      path = cursor.getString(column_index)
      cursor.close()
    }
    if(path == null || path.isEmpty()){
      return uri.getPath()
    }else{
      return path
    }
  }

  private inner class FileCopyTask : AsyncTask<Uri, Void, String?>() {

    override protected fun onPreExecute() {
      super.onPreExecute()
    }


    override protected fun doInBackground(vararg uris: Uri): String? {
      Log.i("FileCopyTask", "doInBackground() called...")
      var copiedFilePath: String? = null
      var errorMessage: String? = null
      if (uris.size <= 0) {
        return null
      }

      val fileUri = uris[0]
      try {
        val destFileName = "test1"
        copiedFilePath = copySelectedFileIntoAppDocs(fileUri, destFileName)

      } catch (e: Exception) {
        e.printStackTrace()
        errorMessage = e.message
      }

      Log.i("FileCopyTask", "doInBackground() copiedFilePath: $copiedFilePath, Error Message: $errorMessage")
      return copiedFilePath
    }


    override protected fun onPostExecute(copiedFilePath: String?) {
      Log.i("FileCopyTask", "onPostExecute() called...")
      resultCb?.success(copiedFilePath)
    }

    @Throws(Exception::class)
    private fun copySelectedFileIntoAppDocs(uri: Uri, destFileName: String): String? {
      Log.i("FilesChooserModule", "=====> copySelectedFileIntoAppDocs() File URI: $uri, DestFileName: $destFileName")
      var fos: FileOutputStream? = null
      var writeToFile: File? = null
      var retFilePath: String? = null
      try {
        val source = File(getPath(uri))
        val filename = uri.getLastPathSegment()
        writeToFile = File(getApplicationContext().getApplicationInfo().dataDir + "/" + filename)
        fos = FileOutputStream(writeToFile);
        val out = BufferedOutputStream(fos)
        val input = context.getContentResolver().openInputStream(uri)

        val buffer = ByteArray(1024)
        var len = 0
        do {

          len = input.read(buffer)
          if(len>0) {
            out.write(buffer, 0, len)
          }
        }while (len>0)
        retFilePath = writeToFile!!.path
      } catch (e: Exception) {
        e.printStackTrace()
        throw e
      } finally {
        try {
          writeToFile = null
        } catch (e: IOException) {
          e.printStackTrace()
        }

      }
      return retFilePath
    }
  }



  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
