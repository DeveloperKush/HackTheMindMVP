import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ScamScreen extends StatefulWidget {
  const ScamScreen({super.key});

  @override
  State<ScamScreen> createState() => _ScamScreenState();
}

class _ScamScreenState extends State<ScamScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _verdict = "";
  String _summary = "";
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _analyze() async {
    if (_controller.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a message or a screenshot")),
      );
      return;
    }

    setState(() {
      _loading = true;
      _verdict = "";
      _summary = "";
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiService.baseUrl}/analyze"),
      );

      if (_controller.text.trim().isNotEmpty) {
        request.fields['text'] = _controller.text.trim();
      }

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      setState(() {
        _verdict = data["verdict"] ?? "";
        _summary = data["summary"] ?? "";
      });
    } catch (e) {
      setState(() => _summary = "Connection error. Please check internet.");
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _getStatusColor() {
    switch (_verdict) {
      case "RED": return const Color(0xFFD32F2F);
      case "YELLOW": return const Color(0xFFF57C00);
      case "GREEN": return const Color(0xFF388E3C);
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Is this message safe?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Paste the text or upload a screenshot of the chat you find suspicious.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // --- INPUT SECTION ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Paste suspicious message here...",
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    fillColor: Colors.grey[50],
                    filled: true,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.image_search, color: Theme.of(context).primaryColor),
                  title: Text(_selectedImage == null ? "Add a screenshot" : "Screenshot added"),
                  trailing: _selectedImage != null 
                    ? IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => setState(() => _selectedImage = null))
                    : const Icon(Icons.add_circle_outline),
                  onTap: _pickImage,
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // --- ACTION BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _loading ? null : _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Scan for Threats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 30),

          // --- RESULT HERO SECTION ---
          if (_verdict.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _getStatusColor().withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _verdict == "RED" ? Icons.dangerous : (_verdict == "GREEN" ? Icons.check_circle : Icons.warning),
                    size: 60,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _verdict == "RED" ? "STAY AWAY" : (_verdict == "GREEN" ? "LOOKS SAFE" : "BE CAUTIOUS"),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _getStatusColor(), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _summary,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF37474F)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}