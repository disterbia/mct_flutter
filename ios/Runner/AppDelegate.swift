import UIKit
import Flutter
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let myChannel = FlutterMethodChannel(name: "my_native_bridge",binaryMessenger: controller.binaryMessenger)

    myChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "set_speaker" else {
        return
      }
      self?.setSpeaker()
    })




    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setSpeaker() {
      do{try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.multiRoute)}
    catch _ {}
  }
}
