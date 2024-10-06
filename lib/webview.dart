import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // Import this for permission handling

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    requestPermission(); // Request permissions when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if the WebView can go back
        if (await _webViewController?.canGoBack() ?? false) {
          _webViewController?.goBack();
          return false; // Prevent the app from exiting
        }
        return true; // Exit the app if WebView cannot go back
      },
      child: Scaffold(
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child: Column(
            children: <Widget>[
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri("https://store.ukayukaysupplier.com/")),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        useOnDownloadStart: true
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onDownloadStartRequest: (controller, url) async {
                    // Handle the file download
                    String fileName = url.url!.toString().split('/').last; // Extract file name
                    await downloadFile(url.url!.toString(), fileName); // Download the file
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading $fileName')),
                    );
                  },
                  androidOnPermissionRequest: (controller, origin, resources) async {
                    return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT,
                    );
                  },
                  onLoadStop: (controller, url) {
                    // This can be used to update UI or stop any loading indicators
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (_webViewController != null) {
      await _webViewController!.reload();
    }
  }

  Future<void> requestPermission() async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (status.isDenied) {
      // Permission denied
      print('Storage permission denied');
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      await openAppSettings(); // Use await with openAppSettings
    }
  }

  // Function to download file and save to external storage
  Future<void> downloadFile(String url, String filename) async {
    try {
      // Validate and parse the URL
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute) {
        throw Exception('Invalid URL: $url');
      }

      // Get the directory to save the file
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Failed to get external storage directory.');
      }
      final filePath = '${directory.path}/$filename'; // Create file path

      // Use the http package to download the file
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes); // Write the response bytes to the file
        print('File downloaded: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded: $filename')),
        );
      } else {
        throw Exception('Failed to download file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }
}
