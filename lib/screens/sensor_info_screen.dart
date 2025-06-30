import 'package:flutter/material.dart';
import '../platform/platform_channel.dart';

class SensorInfoScreen extends StatefulWidget {
  const SensorInfoScreen({super.key});

  @override
  State<SensorInfoScreen> createState() => _SensorInfoScreenState();
}

class _SensorInfoScreenState extends State<SensorInfoScreen> {
  String gyroscopeData = 'No data';

  void _toggleFlashlight() async {
    await PlatformChannel.toggleFlashlight();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Flashlight toggled")));
  }

  void _readGyroscope() async {
    final data = await PlatformChannel.startGyroscope();
    setState(() {
      gyroscopeData = data;
    });
  }

  @override
  void dispose() {
    PlatformChannel.stopGyroscope();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sensor Info'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _toggleFlashlight,
              icon: Icon(Icons.flashlight_on),
              label: Text('Toggle Flashlight'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _readGyroscope,
              icon: Icon(Icons.rotate_90_degrees_ccw),
              label: Text('Read Gyroscope'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.device_hub, color: Colors.green),
                title: Text(
                  "Gyroscope Data",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(gyroscopeData, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
