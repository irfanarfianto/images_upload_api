import 'package:flutter/material.dart';
import 'api_service.dart'; // Pastikan untuk mengimpor service/API yang tepat

class UploadedDataScreen extends StatefulWidget {
  @override
  _UploadedDataScreenState createState() => _UploadedDataScreenState();
}

class _UploadedDataScreenState extends State<UploadedDataScreen> {
  late Future<List<Map<String, String>>> _fetchImageData;

  @override
  void initState() {
    super.initState();
    _fetchImageData = ApiService.fetchUploadedImagesFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Images'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _fetchImageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No uploaded images yet.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String? imageUrl = snapshot.data![index]['image'];
                String? description = snapshot.data![index]['description'];
                String? uploadDate = snapshot.data![index]['upload_date'];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(imageUrl!),
                      SizedBox(height: 8),
                      Text(
                        'Deskripsi: $description',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Tanggal Unggah: $uploadDate',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
