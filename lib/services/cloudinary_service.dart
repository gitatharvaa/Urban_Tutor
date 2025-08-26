import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class CloudinaryService {
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  static final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';
  static final Uuid _uuid = Uuid();

  // Upload image to Cloudinary
  static Future<String> uploadImage(File imageFile, String folder) async {
    try {
      final uri = Uri.parse('$_baseUrl/$_cloudName/image/upload');

      // Create unique filename
      final fileName = '${_uuid.v4()}.jpg';

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add the file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: fileName,
      ));

      // Add required parameters
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder; // e.g., 'urban_tutor/profile_images'

      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseString);
        return data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  // General upload method
  static Future<String> upload(File file,
      {String folder = 'urban_tutor', bool isRaw = false}) async {
    final uri = Uri.parse('$_baseUrl/$_cloudName/${isRaw ? 'raw' : 'image'}/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', file.path,
          filename: '${_uuid.v4()}.${file.path.split('.').last}'));

    final res = await req.send();
    final body = utf8.decode(await res.stream.toBytes());

    if (res.statusCode == 200) {
      return json.decode(body)['secure_url'] as String;
    } else {
      throw Exception('Cloudinary upload failed: $body');
    }
  }

  // Upload document (qualification) to Cloudinary
  static Future<String> uploadDocument(File documentFile, String folder) async {
    try {
      final uri = Uri.parse('$_baseUrl/$_cloudName/raw/upload'); // 'raw' for documents

      // Create unique filename
      final fileName = '${_uuid.v4()}.pdf';

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add the file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        documentFile.path,
        filename: fileName,
      ));

      // Add required parameters
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder; // e.g., 'urban_tutor/documents'

      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseString);
        return data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Document upload failed: ${e.toString()}');
    }
  }

  // Delete file from Cloudinary (requires API key and secret)
  static Future<bool> deleteFile(String publicId) async {
    try {
      final apiKey = dotenv.env['CLOUDINARY_API_KEY']!;
      final apiSecret = dotenv.env['CLOUDINARY_API_SECRET']!;
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Create signature for authenticated request
      final signature = _generateSignature(publicId, timestamp, apiSecret);

      final uri = Uri.parse('$_baseUrl/$_cloudName/image/destroy');

      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Delete failed: ${e.toString()}');
      return false;
    }
  }

  // Generate signature for authenticated requests
  static String _generateSignature(String publicId, String timestamp, String apiSecret) {
    // This is a simplified signature generation
    // In production, use proper SHA-1 HMAC signature
    return 'signature_placeholder';
  }

  // Get optimized image URL
  static String getOptimizedImageUrl(String imageUrl, {int? width, int? height}) {
    if (imageUrl.contains('cloudinary.com')) {
      // Insert transformation parameters into existing Cloudinary URL
      final parts = imageUrl.split('/upload/');
      if (parts.length == 2) {
        String transformations = '';
        if (width != null) transformations += 'w_$width,';
        if (height != null) transformations += 'h_$height,';
        if (transformations.isNotEmpty) {
          transformations += 'c_fill,q_auto,f_auto';
          return '${parts[0]}/upload/$transformations/${parts[1]}';
        }
      }
    }
    return imageUrl;
  }
}
