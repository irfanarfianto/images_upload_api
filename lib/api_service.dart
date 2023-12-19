import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.10.24.34/flutter_image/";

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
