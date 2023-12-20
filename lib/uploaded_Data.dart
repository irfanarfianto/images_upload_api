import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class UploadedImagesPage extends StatefulWidget {
  @override
  _UploadedImagesPageState createState() => _UploadedImagesPageState();
}

class _UploadedImagesPageState extends State<UploadedImagesPage> {
  List<Map<String, dynamic>> imageList = [];
  late List<Map<String, dynamic>> searchResult = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    final response = await http.get(Uri.parse("http://10.10.24.34/flutter_image/get_uploaded_images.php"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> sortedImageList = List<Map<String, dynamic>>.from(jsonData);

      sortedImageList.sort((a, b) {
        DateTime? timeA = DateTime.tryParse(a['upload_time']);
        DateTime? timeB = DateTime.tryParse(b['upload_time']);

        if (timeA == null || timeB == null) return 0;

        return timeB.compareTo(timeA);
      });

      setState(() {
        imageList = sortedImageList;
        searchResult = List.from(imageList);
      });
    } else {
      // Handle error
      print("Failed to fetch images: ${response.statusCode}");
    }
  }

  Future<void> _refreshImages() async {
    await fetchImages();
  }

  String formatUploadTime(String? uploadTimeString) {
    if (uploadTimeString != null) {
      DateTime? uploadTime = DateTime.tryParse(uploadTimeString);
      if (uploadTime != null) {
        return timeago.format(uploadTime, locale: 'id_short'); // Format waktu menggunakan timeago
      }
    }
    return "Unknown upload time";
  }

  void _performSearch(String query) {
    setState(() {
      searchResult = imageList.where((image) {
        final description = image['description'].toString().toLowerCase();
        final uploadTime = formatUploadTime(image['upload_time']).toLowerCase();
        return description.contains(query.toLowerCase()) || uploadTime.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshImages,
              child: ListView.builder(
                itemCount: searchResult.length,
                itemBuilder: (context, index) {
                  final imageInfo = searchResult[index];
                  final imageUrl = "http://10.10.24.34/flutter_image/uploads/${imageInfo['file_name']}";
                  final uploadTime = formatUploadTime(imageInfo['upload_time']);

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                imageInfo['description'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Uploaded $uploadTime",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
