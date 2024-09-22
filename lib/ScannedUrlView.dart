import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'QrCodeScanner.dart';
import 'main.dart';

class ScannedUrlView extends StatefulWidget {
  final String url;
  const ScannedUrlView({super.key, required this.url});

  @override
  _ScannedUrlViewState createState() => _ScannedUrlViewState();
}


class _ScannedUrlViewState extends State<ScannedUrlView> {
  Map<String, dynamic>? scanResult;
  bool isLoading = true;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    _analyzeUrl();
  }

  Future<void> _launchUrl() async {
    var uri = Uri.parse(widget.url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $widget.url');
    }
  }
  Future<void> _analyzeUrl() async {
    final String apiUrl = 'https://api.ssllabs.com/api/v3/analyze?host=${widget.url}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          scanResult = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const MyHome(),
            ));
          },
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage != null
            ? Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        )
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.url,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scan Results:',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 2),

                child: Text(
                  'Grade: ${scanResult?['endpoints']?[0]?["grade"]}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () => _launchUrl(),
                child: const Text('Go to the page'),
              ),
              TextButton(
                child: const Text('Scan again'),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MyHome(),
                    ))
              ),
            ],
          ),
        ),
      ),
    );
  }
}
