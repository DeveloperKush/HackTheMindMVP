import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your actual hosted URL or local IP (e.g., http://10.0.2.2:5000 for Android Emulator)
  static const String baseUrl = "http://YOUR_BACKEND_URL";

  /// 1. Analyze Scams (Supports Text and/or Image)
  /// This uses MultipartRequest to handle file uploads
  static Future<Map<String, dynamic>> analyzeScam({String? text, File? image}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/analyze"));

      if (text != null && text.isNotEmpty) {
        request.fields['text'] = text;
      }

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('file', image.path));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"verdict": "ERROR", "summary": "Server returned an error (${response.statusCode})"};
      }
    } catch (e) {
      return {"verdict": "ERROR", "summary": "Connection failed. Please check your internet."};
    }
  }

  /// 2. Get Recovery Steps (Help)
  static Future<Map<String, dynamic>> getHelp(String incident) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/help"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"incident": incident}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"steps": ["Could not fetch help steps at this moment." ]};
    } catch (e) {
      return {"steps": ["Connection error. Please call 1930 directly." ]};
    }
  }

  /// 3. Fact Checking Engine
  static Future<Map<String, dynamic>> factCheck(String text) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/factcheck"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"result": "UNKNOWN", "explanation": "Failed to verify the claim."};
    } catch (e) {
      return {"result": "ERROR", "explanation": "Network error. Please try again later."};
    }
  }
}