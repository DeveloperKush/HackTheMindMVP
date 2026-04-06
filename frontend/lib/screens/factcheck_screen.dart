import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FactCheckScreen extends StatefulWidget {
  const FactCheckScreen({super.key});

  @override
  State<FactCheckScreen> createState() => _FactCheckScreenState();
}

class _FactCheckScreenState extends State<FactCheckScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  String _explanation = "";
  bool _loading = false;

  Future<void> _check() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      final data = await ApiService.factCheck(_controller.text);
      setState(() {
        _result = data["result"] ?? "";
        _explanation = data["explanation"] ?? "";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification failed. Check your connection.")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _getResultColor() {
    switch (_result.toUpperCase()) {
      case "TRUE": return const Color(0xFF2E7D32); // Deep Green
      case "FALSE": return const Color(0xFFC62828); // Deep Red
      case "MISLEADING": return const Color(0xFFEF6C00); // Deep Orange
      default: return Colors.blueGrey;
    }
  }

  IconData _getResultIcon() {
    switch (_result.toUpperCase()) {
      case "TRUE": return Icons.verified_user;
      case "FALSE": return Icons.cancel;
      case "MISLEADING": return Icons.error_outline;
      default: return Icons.help_outline;
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
            "Verify Information",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Paste news, claims, or rumors to check if they are real or fake.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // --- INPUT BOX ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter the claim here...",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _check,
              icon: const Icon(Icons.search),
              label: const Text("Verify Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853), // Success Green
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // --- VERDICT SECTION ---
          if (_loading) 
            const Center(child: CircularProgressIndicator())
          else if (_result.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _getResultColor().withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: _getResultColor().withOpacity(0.1), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getResultColor(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getResultIcon(), color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _result,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "AI Analysis",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF263238)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}