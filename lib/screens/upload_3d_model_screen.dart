import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sample_project/screens/login_screen.dart';
import '../database_service.dart';
import '../constants.dart';
import '../session_manager.dart';

class Upload3DModelScreen extends StatefulWidget {
  const Upload3DModelScreen({super.key});

  @override
  State<Upload3DModelScreen> createState() => _Upload3DModelScreenState();
}

class _Upload3DModelScreenState extends State<Upload3DModelScreen> {
  final TextEditingController _skuController = TextEditingController();
  File? _selectedModel;
  var businessId;
  bool _isUploading = false;
  bool isLoading = true;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _fetchBusinessProducts();
  }

  Future<void> _fetchBusinessProducts() async {
    var session = await SessionManager.getUserSession();
    String? email = session['email'];
    if (email != null) {
      var user = await DatabaseService.getUserByEmail(email);
      var business = await DatabaseService.getBusiness(user!['business']);
      var fetchedProducts = await DatabaseService.getProducts(business!['_id']);

      setState(() {
        businessId = business['_id'];
        products = fetchedProducts;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session ended. Please login again!')),
      );
      logout();
    }
  }

  void logout() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _upload3DModel() async {
    if (_skuController.text.isEmpty || _selectedModel == null) {
      _showMessage('Please enter SKU and select a 3D model.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    var product = await DatabaseService.getProductBySKU(
      _skuController.text,
      businessId!,
    );
    if (product == null) {
      _showMessage('No product found with this SKU.');
      setState(() => _isUploading = false);
      return;
    }

    try {
      await DatabaseService.upload3DModel(
        _skuController.text,
        businessId,
        _selectedModel!.path,
      );
      _showMessage('3D model assigned successfully!');
    } catch (e) {
      _showMessage('Error uploading model: $e');
    } finally {
      DatabaseService.initialize3DModelFields(_skuController.text, businessId);
      setState(() {
        _isUploading = false;
      });
    }
  }

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Upload 3D Model',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: buttonColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Products:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: buttonColor),
                      )
                      : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var product = products[index];
                          return Card(
                            color: Colors.white,
                            shadowColor: buttonColor,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                product['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                'SKU: ${product['sku']}\nPrice: Rs ${product['price']}',
                                style: const TextStyle(color: textColor),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pick3DModel,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text('Select 3D Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: fieldBackgroundColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_selectedModel != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Selected: ${_selectedModel!.path.split('/').last}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _upload3DModel,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading ? Colors.grey : buttonColor,
                foregroundColor: fieldBackgroundColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isUploading
                      ? const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        child: CircularProgressIndicator(color: buttonColor),
                      )
                      : const Text('Upload Model'),
            ),
          ],
        ),
      ),
    );
  }
}
