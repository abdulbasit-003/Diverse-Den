import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_service.dart';
import '../constants.dart';

class Upload3DModelScreen extends StatefulWidget {
  const Upload3DModelScreen({super.key});

  @override
  State<Upload3DModelScreen> createState() => _Upload3DModelScreenState();
}

class _Upload3DModelScreenState extends State<Upload3DModelScreen> {
  final TextEditingController _skuController = TextEditingController();
  File? _selectedModel;
  String? _businessId;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchBusinessId();
  }

  /// Fetch Business ID from SharedPreferences
  Future<void> _fetchBusinessId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _businessId = prefs.getString('businessId');
    });
  }

  /// Select 3D Model File (.glb, .gltf)
  Future<void> _pick3DModel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        String fileExtension = filePath.split('.').last.toLowerCase();

        if (fileExtension == 'glb' || fileExtension == 'gltf') {
          setState(() {
            _selectedModel = File(filePath);
          });
        } else {
          _showMessage('Invalid file format. Only .glb and .gltf are allowed.');
        }
      }
    } catch (e) {
      _showMessage('Error selecting file: $e');
    }
  }

  /// Check if SKU exists in the database
  Future<bool> _checkIfProductExists(String sku) async {
    if (_businessId == null) {
      _showMessage('Business ID not found. Please re-login.');
      return false;
    }

    var product = await DatabaseService.getProductBySKU(sku, _businessId!);
    return product != null;
  }

  /// Upload 3D Model to MongoDB
  Future<void> _upload3DModel() async {
    if (_skuController.text.isEmpty || _selectedModel == null) {
      _showMessage('Please enter SKU and select a 3D model.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    bool productExists = await _checkIfProductExists(_skuController.text);
    if (!productExists) {
      _showMessage('No product found with this SKU in your business.');
      setState(() {
        _isUploading = false;
      });
      return;
    }

    try {
      await DatabaseService.upload3DModel(
          _skuController.text, _businessId!, _selectedModel!.path);

      _showMessage('3D model uploaded successfully!');
    } catch (e) {
      _showMessage('Error uploading model: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// Show Snackbar Message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _skuController,
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Enter Product SKU',
                labelStyle: const TextStyle(color: textColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pick3DModel,
              icon: const Icon(Icons.upload_file, color: Colors.white,),
              label: const Text('Select 3D Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: fieldBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_selectedModel != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,),
                child: Text(
                  'Selected: ${_selectedModel!.path.split('/').last}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (_selectedModel == null || _isUploading) ? null : _upload3DModel,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading ? Colors.grey : buttonColor,
                foregroundColor: fieldBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: fieldBackgroundColor),
                    )
                  : const Text('Upload Model'),
            ),
          ],
        ),
      ),
    );
  }
}
