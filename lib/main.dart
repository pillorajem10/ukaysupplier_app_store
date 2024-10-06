import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'webview.dart'; // Import your WebViewPage here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions
  await _requestPermissions();

  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  // Request permissions
  final status = await [
    Permission.camera,
    Permission.microphone,
    Permission.photos, // For media access
    Permission.storage, // For file storage access
  ].request();

  // Check if permissions are granted
  if (status[Permission.storage] != PermissionStatus.granted) {
    // Handle case when storage permission is not granted
    print('Storage permission not granted');
    if (status[Permission.storage] == PermissionStatus.permanentlyDenied) {
      // Open app settings if the permission is permanently denied
      await openAppSettings();
    }
  }
  // Handle other permissions similarly if needed
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Disable the debug banner here
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(color: Colors.black),  // Set the title color to black
          ),
          centerTitle: true, // Center the title
          backgroundColor: Colors.white, // Change the AppBar background color to white
          iconTheme: IconThemeData(color: Colors.black), // Change the color of the AppBar icons (like back button) to black
          elevation: 0, // Optional: remove shadow under AppBar
          toolbarHeight: 15.0, // Set the height of the AppBar (e.g., 80.0 pixels)
        ),
        body: WebViewPage(), // Your WebView page goes here
      ),
    );
  }
}
