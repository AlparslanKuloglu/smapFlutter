import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerHapticsChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  /// Notification feedback for `AppHaptics` (lib/core/services/app_haptics.dart).
  /// Flutter's HapticFeedback only covers impacts and selection, so "success" and
  /// "error" come through this channel. The system haptics setting silences them.
  private func registerHapticsChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "smap/haptics", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      let type: UINotificationFeedbackGenerator.FeedbackType
      switch call.method {
      case "success": type = .success
      case "error": type = .error
      default:
        result(FlutterMethodNotImplemented)
        return
      }
      UINotificationFeedbackGenerator().notificationOccurred(type)
      result(nil)
    }
  }
}
