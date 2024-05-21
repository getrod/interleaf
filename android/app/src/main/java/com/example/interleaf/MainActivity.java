package com.example.interleaf;

import android.os.Bundle;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import org.opencv.android.OpenCVLoader;
import org.opencv.core.Core;
import org.opencv.core.Mat;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.interleaf.platform";

  static {
    if (!OpenCVLoader.initDebug()){
      Log.e("OpenCv", "Unable to load OpenCV");
    } else {
      Log.d("OpenCv", "OpenCV loaded");
    }
  }


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
          case "createIndexCard":
            String path = call.argument("path");
            String picSetting = call.argument("picSetting");
            System.out.println("picSetting: " + picSetting);
            boolean succsessful = CardMaker.createIndexCard(path, picSetting);
            result.success(succsessful);

            if (!succsessful) {
              System.out.println("IndexCard method returned: " + succsessful);
              //result.success("Cannot create index card");
              //result.error("UNAVAILABLE", "Cannot Create Index Card", null);
            } else {
              //result.success("Index Card created");
              System.out.println("After result.success. Should return to dart");
            }
            break;
          default:
            result.notImplemented();
            break;
        }
      }
    });

  }
}
