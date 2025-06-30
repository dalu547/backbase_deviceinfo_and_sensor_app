import UIKit
import Flutter
import CoreMotion
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let motionManager = CMMotionManager()
    private var flashlightOn = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let deviceChannel = FlutterMethodChannel(name: "device_info_channel", binaryMessenger: controller.binaryMessenger)

        deviceChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getBatteryLevel":
                UIDevice.current.isBatteryMonitoringEnabled = true
                let level = UIDevice.current.batteryLevel
                result("\(Int(level * 100))%")

            case "getDeviceName":
                result(UIDevice.current.name)

            case "getOSVersion":
                result(UIDevice.current.systemVersion)

            case "toggleFlashlight":
                self?.toggleFlashlight(result: result)

            case "startGyroscope":
                self?.startGyroscope(result: result)

            case "stopGyroscope":
                self?.motionManager.stopGyroUpdates()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func toggleFlashlight(result: FlutterResult) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video),
              device.hasTorch else {
            result("Torch not available")
            return
        }

        do {
            try device.lockForConfiguration()
            if flashlightOn {
                device.torchMode = .off
                flashlightOn = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                flashlightOn = true
            }
            device.unlockForConfiguration()
            result("Flashlight toggled")
        } catch {
            result("Failed to toggle flashlight: \(error.localizedDescription)")
        }
    }

    private func startGyroscope(result: FlutterResult) {
        guard motionManager.isGyroAvailable else {
            result("Gyroscope not available")
            return
        }

        motionManager.gyroUpdateInterval = 1.0
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            if let gyroData = data {
                let x = gyroData.rotationRate.x
                let y = gyroData.rotationRate.y
                let z = gyroData.rotationRate.z
                result("x: \(x.toString()), y: \(y.toString()), z: \(z.toString())")
                self.motionManager.stopGyroUpdates()
            } else if let error = error {
                result("Error reading gyroscope: \(error.localizedDescription)")
            }
        }
    }
}

extension Double {
    func toString() -> String {
        return String(format: "%.2f", self)
    }
}
