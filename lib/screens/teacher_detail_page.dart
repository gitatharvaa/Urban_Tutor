import 'package:flutter/material.dart';

class TeacherDetailPage extends StatelessWidget {
  final Map<String, dynamic> teacher; //string

  const TeacherDetailPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teacher['name'] ?? 'Teacher Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  teacher['imageUrl'] ?? '',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 120),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              teacher['name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              teacher['location'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              "Qualification: ${teacher['qualification'] ?? ''}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Experience: ${teacher['experience'] ?? ''}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Subject: ${teacher['subject'] ?? ''}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
