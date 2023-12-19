import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.8/flutter_image/";

// Fungsi untuk mengambil daftar gambar yang telah diunggah
  static Future<List<Map<String, String>>> fetchUploadedImagesFromDB() async {
    try {
      final Uri uri = Uri.parse(baseUrl + 'get_uploaded_images.php');
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Map<String, dynamic>> imageDetails = jsonResponse.map((data) {
          return {
            'image': baseUrl + (data['file_path'] ?? ''),
            'description': data['description'] ?? '',
            'upload_date': data['upload_time'] ?? ''
          };
        }).toList();

        // Perform a type cast to resolve the type mismatch
        return imageDetails.cast<Map<String, String>>();
      } else {
        throw 'Failed to fetch uploaded images. Status Code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching uploaded images: $e';
    }
  }

  static Future<String> uploadImage(File imageFile, String description) async {
    try {
      final uri = Uri.parse(baseUrl + 'upload_image.php');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path))
        ..fields['description'] = description;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey('message')) {
          return jsonResponse['message'];
        } else {
          return 'Failed to upload image: Invalid response format';
        }
      } else {
        return 'Failed to upload image. Status Code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error uploading image: $e';
    }
  }
}
