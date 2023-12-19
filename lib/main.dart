import 'dart:async'; // Perbaikan 1
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_upload_api/uploaded_Data.dart';
import 'api_service.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

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
        showToast(
          'Eittss.. Kamu belum isi deskripsinya, nih!',
          context: context,
          duration: Duration(seconds: 3),
          position: StyledToastPosition.top,
          animation: StyledToastAnimation.slideFromTop,
          curve: Curves.bounceOut,
          reverseAnimation: StyledToastAnimation.slideToTopFade,
        );
        return;
      }

      try {
        await ApiService.uploadImage(_imageFile!, description);

        setState(() {
          _imageFile = null;
          _descriptionController.clear();
        });

        showToast(
          '✅ Yeyy.. Foto berhasil diupload!',
          context: context,
          duration: Duration(seconds: 5),
          animation: StyledToastAnimation.fade,
          position: StyledToastPosition.top,
          animDuration: Duration(milliseconds: 250),
          curve: Curves.bounceOut,
          reverseAnimation: StyledToastAnimation.slideToTopFade,
        );
      } catch (e) {
        showToast(
          'Gagal upload fotonya nih, coba lagi ya!',
          context: context,
          duration: Duration(seconds: 3),
          position: StyledToastPosition.top,
          animation: StyledToastAnimation.slideFromTop,
          curve: Curves.bounceOut,
          reverseAnimation: StyledToastAnimation.slideToTopFade,
        );
      }
    } else {
      showToast(
        'Belum ada fotonya, nih!',
        context: context,
        duration: Duration(seconds: 3),
        position: StyledToastPosition.top,
        animation: StyledToastAnimation.slideFromTop,
        curve: Curves.bounceOut,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Upload Example',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list_alt_outlined),
            onPressed: () {
              // Tambahkan aksi ke UploadedDataScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadedDataScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ),
              Spacer(), // Menggunakan Spacer untuk fleksibilitas ruang kosong
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text("Upload Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
