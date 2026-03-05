import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "system_time_guard/events"
  private var eventSink: FlutterEventSink?
  private var timeStreamHandler: TimeChangeStreamHandler?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let eventChannel = FlutterEventChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )

      timeStreamHandler = TimeChangeStreamHandler()
      eventChannel.setStreamHandler(timeStreamHandler)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

final class TimeChangeStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    startObservers()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopObservers()
    eventSink = nil
    return nil
  }

  private func startObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleSignificantTimeChange),
      name: UIApplication.significantTimeChangeNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleTimezoneChange),
      name: NSNotification.Name.NSSystemTimeZoneDidChange,
      object: nil
    )

    // اختياري: تغيير اليوم
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDayChanged),
      name: NSNotification.Name.NSCalendarDayChanged,
      object: nil
    )
  }

  private func stopObservers() {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func handleSignificantTimeChange() {
    sendEvent(type: "significant_time_change")
  }

  @objc private func handleTimezoneChange() {
    sendEvent(type: "timezone_changed")
  }

  @objc private func handleDayChanged() {
    sendEvent(type: "date_changed")
  }

  private func sendEvent(type: String) {
    let payload: [String: Any] = [
      "type": type,
      "timestamp": Int(Date().timeIntervalSince1970 * 1000)
    ]
    eventSink?(payload)
  }

  deinit {
    stopObservers()
  }
}