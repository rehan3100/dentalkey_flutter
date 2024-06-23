import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var field: UITextField!

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.dentalkeybydrrehan.dentalkey/screenshot", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      switch call.method {
      case "enableScreenshotRestriction":
        self.enableScreenshotRestriction()
        print("enableScreenshotRestriction called")
        result(nil)
      case "disableScreenshotRestriction":
        self.disableScreenshotRestriction()
        print("disableScreenshotRestriction called")
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    let deviceIdChannel = FlutterMethodChannel(name: "com.dentalkeybydrrehan.dentalkey/device_id", binaryMessenger: controller.binaryMessenger)
    deviceIdChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      if call.method == "getSecureVendorIdentifier" {
        let vendorId = self.getSecureVendorIdentifier()
        result(vendorId)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
/*    let settingsChannel = FlutterMethodChannel(name: "com.dentalkeybydrrehan.dentalkey/settings", binaryMessenger: controller.binaryMessenger)
    settingsChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      if call.method == "openSettings" {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
          result(true)
        } else {
          result(FlutterError(code: "UNAVAILABLE", message: "Cannot open settings", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
*/    
    self.addSecureView()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    field?.isSecureTextEntry = false
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    field?.isSecureTextEntry = true
  }

  private func addSecureView() {
    field = UITextField()
    field.translatesAutoresizingMaskIntoConstraints = false
    field.isSecureTextEntry = true
    if let window = UIApplication.shared.windows.first {
      if !window.subviews.contains(field) {
        window.addSubview(field)
        field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        window.layer.superlayer?.addSublayer(field.layer)
        if #available(iOS 17.0, *) {
          field.layer.sublayers?.last?.addSublayer(window.layer)
        } else {
          field.layer.sublayers?.first?.addSublayer(window.layer)
        }
      }
    }
  }

  private func enableScreenshotRestriction() {
    if let window = UIApplication.shared.windows.first {
      addSecureView()
    }
  }

  private func disableScreenshotRestriction() {
    if let window = UIApplication.shared.windows.first {
      for subview in window.subviews {
        if subview is UITextField && (subview as! UITextField).isSecureTextEntry {
          subview.removeFromSuperview()
        }
      }
    }
  }

  private func getSecureVendorIdentifier() -> String {
    let key = "com.dentalkeybydrrehan.secureVendorIdentifier"
    if let vendorIdentifier = readKeychainValue(forKey: key) {
      return vendorIdentifier
    } else {
      let newVendorIdentifier = UIDevice.current.identifierForVendor!.uuidString
      saveKeychainValue(newVendorIdentifier, forKey: key)
      return newVendorIdentifier
    }
  }

  private func saveKeychainValue(_ value: String, forKey key: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: data
    ]
    SecItemAdd(query as CFDictionary, nil)
  }

  private func readKeychainValue(forKey key: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: kCFBooleanTrue!,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)
    if let data = result as? Data {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
}