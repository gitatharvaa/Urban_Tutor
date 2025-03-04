// lib/services/notes_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NotesApiService {
  static const String baseUrl = 'http://192.168.0.102:3000/api'; // For Android emulator
  // Use 'http://localhost:3000/api' for iOS simulator

  Future<Map<String, dynamic>> uploadNote({
    required String title,
    required String description,
    required String subject,
    required String difficulty,
    required String grade,
    required String schoolName,
    required String uploaderName,
    required File file,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/notes'),
      );

      // Add text fields
      request.fields.addAll({
        'title': title,
        'description': description,
        'subject': subject,
        'difficulty': difficulty,
        'grade': grade,
        'schoolName': schoolName,
        'uploaderName': uploaderName,
      });

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf',
          file.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading note: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotes({
    required String grade,
    String? subject,
    String? difficulty,
  }) async {
    try {
      final queryParams = {
        'grade': grade,
        if (subject != null && subject != 'All') 'subject': subject,
        if (difficulty != null && difficulty != 'All') 'difficulty': difficulty,
      };

      final uri = Uri.parse('$baseUrl/notes').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }
}