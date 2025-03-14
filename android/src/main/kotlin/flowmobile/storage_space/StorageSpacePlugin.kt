package flowmobile.storage_space

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import  android.os.StatFs
import  android.os.Environment

/** StorageSpacePlugin */
public class StorageSpacePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "storage_space")
    channel.setMethodCallHandler(this);
  }
  
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if(call.method == "getFreeSpace"){
      val stat = StatFs(Environment.getDataDirectory().getPath())
      val bytesAvailable = stat.getFreeBytes()
      result.success(bytesAvailable)
    }
    else if(call.method == "getTotalSpace"){
      val stat = StatFs(Environment.getDataDirectory().getPath())
      val bytesTotal = stat.getTotalBytes()
      result.success(bytesTotal)
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

}
