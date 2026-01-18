import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() => _characterCount = _textController.text.length);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('Please enter some text', isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    await _firestore.addPost(_textController.text.trim(), user.email!);
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Container(decoration: AppTheme.gradientBackground),
          const Positioned.fill(child: FloatingParticles()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                        ).createShader(bounds),
                        child: const Text(
                          'Create Post',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(4),
                          child: TextField(
                            controller: _textController,
                            maxLines: 8,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: "What's on your mind?",
                              hintStyle: const TextStyle(color: AppTheme.textHint),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$_characterCount characters',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        GradientButton(
                          text: 'Publish Post',
                          icon: Icons.send_rounded,
                          onPressed: _handleUpload,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
