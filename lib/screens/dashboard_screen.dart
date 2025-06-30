import 'package:flutter/material.dart';
import '../platform/platform_channel.dart';
import '../widgets/loading_animation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String battery = 'Loading...';
  String deviceName = 'Loading...';
  String osVersion = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeviceInfo();
  }

  void fetchDeviceInfo() async {
    try {
      final batteryLevel = await PlatformChannel.getBatteryLevel();
      final name = await PlatformChannel.getDeviceName();
      final os = await PlatformChannel.getOSVersion();

      setState(() {
        battery = batteryLevel;
        deviceName = name;
        osVersion = os;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        battery = 'Error';
        deviceName = 'Error';
        osVersion = 'Error';
        isLoading = false;
      });
    }
  }

  Widget buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Info"),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: LoadingAnimation())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildInfoCard("Battery Level", battery, Icons.battery_full),
                    buildInfoCard("Device Name", deviceName, Icons.smartphone),
                    buildInfoCard("OS Version", osVersion, Icons.system_update),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/sensor'),
                      icon: Icon(Icons.sensors),
                      label: Text("Go to Sensor Info"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
