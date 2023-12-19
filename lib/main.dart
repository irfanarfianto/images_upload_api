import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_upload_api/data_upload.dart';
import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageUploadWidget(),
    );
  }
}

class ImageUploadWidget extends StatefulWidget {
  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _imageFile;
  TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      final description = _descriptionController.text;

      if (description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a description')));
        return;
      }

      try {
        final result = await ApiService.uploadImage(_imageFile!, description);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result)));

        setState(() {
          _imageFile = null;
          _descriptionController.clear();
        });

        // Tampilkan pop-up saat berhasil mengunggah
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Image uploaded successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup pop-up
                    Navigator.of(context).push(
                      // Buka halaman data setelah menutup pop-up
                      MaterialPageRoute(
                        builder: (context) => UploadedDataScreen(
                            []), // Ganti dengan data yang sesuai
                      ),
                    ); // Kembali ke layar sebelumnya
                  },
                  child: Text('Back'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upload image. Please try again later.')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please take a picture first')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey,
                    child:
                        Icon(Icons.camera_alt, size: 50, color: Colors.white),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: Text("Take Picture"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text("Upload Image"),
            ),
          ],
        ),
      ),
    );
  }
}
