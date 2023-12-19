import 'dart:io';
import 'package:flutter/material.dart';

class UploadedDataScreen extends StatelessWidget {
  final List<Map<String, dynamic>> uploadedData;

  UploadedDataScreen(this.uploadedData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Data'),
      ),
      body: ListView.builder(
        itemCount: uploadedData.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.file(
                uploadedData[index]['image'] as File,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              title: Text('Description: ${uploadedData[index]['description']}'),
            ),
          );
        },
      ),
    );
  }
}
