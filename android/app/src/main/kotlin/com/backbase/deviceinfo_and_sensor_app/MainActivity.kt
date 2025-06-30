package com.backbase.deviceinfo_and_sensor_app

import android.os.Build
import android.os.BatteryManager
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.camera2.CameraManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device_info_channel"
    private var isFlashOn = false
    private var sensorManager: SensorManager? = null
    private var gyroscopeSensor: Sensor? = null
    private var gyroscopeListener: SensorEventListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                    result.success("$batteryLevel%")
                }

                "getDeviceName" -> {
                    result.success(Build.MODEL)
                }

                "getOSVersion" -> {
                    result.success(Build.VERSION.RELEASE)
                }

                "toggleFlashlight" -> {
                    try {
                        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                        val cameraId = cameraManager.cameraIdList.first()
                        isFlashOn = !isFlashOn
                        cameraManager.setTorchMode(cameraId, isFlashOn)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("FLASH_ERROR", "Flashlight toggle failed: ${e.message}", null)
                    }
                }

                "startGyroscope" -> {
                    sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    gyroscopeSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

                    if (gyroscopeSensor == null) {
                        result.error("NO_SENSOR", "Gyroscope sensor not available", null)
                        return@setMethodCallHandler
                    }

                    gyroscopeListener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent) {
                            val data = "x: ${event.values[0]}, y: ${event.values[1]}, z: ${event.values[2]}"
                            result.success(data)
                            sensorManager?.unregisterListener(this)
                        }

                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }

                    sensorManager?.registerListener(
                        gyroscopeListener,
                        gyroscopeSensor,
                        SensorManager.SENSOR_DELAY_NORMAL
                    )
                }

                "stopGyroscope" -> {
                    if (gyroscopeListener != null) {
                        sensorManager?.unregisterListener(gyroscopeListener)
                        gyroscopeListener = null
                    }
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
