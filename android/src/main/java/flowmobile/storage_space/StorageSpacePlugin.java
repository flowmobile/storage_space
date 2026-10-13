package flowmobile.storage_space;

import android.app.usage.StorageStats;
import android.app.usage.StorageStatsManager;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Process;
import android.os.StatFs;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** StorageSpacePlugin */
public class StorageSpacePlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private Context context;
  private ExecutorService executor;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    executor = Executors.newSingleThreadExecutor();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "storage_space");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getFreeSpace":
        // Available bytes exclude the blocks reserved for the system, so this is
        // the space apps can actually use (as on iOS)
        result.success(new StatFs(Environment.getDataDirectory().getPath()).getAvailableBytes());
        break;
      case "getTotalSpace":
        result.success(new StatFs(Environment.getDataDirectory().getPath()).getTotalBytes());
        break;
      case "getAppStorageUsage":
        // Walking directories (and on newer devices, querying storage stats)
        // can be slow, so keep it off the main thread.
        executor.execute(() -> {
          try {
            Map<String, Long> usage = getAppStorageUsage();
            mainHandler.post(() -> result.success(usage));
          } catch (Exception e) {
            mainHandler.post(() -> result.error("APP_USAGE_ERROR", e.getMessage(), null));
          }
        });
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    executor.shutdown();
  }

  /**
   * Storage used by this app, in bytes, matching Settings > Apps > Storage.
   *
   * "data" includes "cache", and "app" + "data" is the total.
   */
  private Map<String, Long> getAppStorageUsage() throws Exception {
    ApplicationInfo info = context.getApplicationInfo();
    long app;
    long data;
    long cache;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      // No permission is needed to query the calling app's own package
      StorageStatsManager manager =
          (StorageStatsManager) context.getSystemService(Context.STORAGE_STATS_SERVICE);
      StorageStats stats =
          manager.queryStatsForPackage(info.storageUuid, context.getPackageName(), Process.myUserHandle());
      app = stats.getAppBytes();
      data = stats.getDataBytes();
      cache = stats.getCacheBytes();
    } else {
      app = sizeOf(new File(info.sourceDir));
      if (info.splitSourceDirs != null) {
        for (String split : info.splitSourceDirs) {
          app += sizeOf(new File(split));
        }
      }
      data = sizeOf(new File(info.dataDir));
      cache = sizeOf(context.getCacheDir()) + sizeOf(context.getCodeCacheDir());
    }
    Map<String, Long> usage = new HashMap<>();
    usage.put("app", app);
    usage.put("data", data);
    usage.put("cache", cache);
    return usage;
  }

  /** Size of a file, or the total size of a directory tree (symlinks are not followed) */
  private static long sizeOf(File file) throws IOException {
    if (file == null || !file.exists() || isSymlink(file)) {
      return 0;
    }
    if (!file.isDirectory()) {
      return file.length();
    }
    long size = 0;
    File[] children = file.listFiles();
    if (children != null) {
      for (File child : children) {
        size += sizeOf(child);
      }
    }
    return size;
  }

  private static boolean isSymlink(File file) throws IOException {
    File parent = file.getParentFile();
    File canonicalDir = parent == null ? file : new File(parent.getCanonicalFile(), file.getName());
    return !canonicalDir.getCanonicalFile().equals(canonicalDir.getAbsoluteFile());
  }
}
