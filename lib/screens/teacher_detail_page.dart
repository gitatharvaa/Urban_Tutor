import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import '../utils/app_colors.dart';

class TeacherDetailPage extends StatelessWidget {
  final TutorModel tutor;

  const TeacherDetailPage({
    super.key,
    required this.tutor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tutor.personalInfo.fullName),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image and basic info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.background,
                    child: tutor.personalInfo.profileImageUrl.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: tutor.personalInfo.profileImageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CircularProgressIndicator(
                                color: AppColors.primaryBlue,
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primaryBlue,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tutor.personalInfo.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tutor.professionalInfo.qualification,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detailed information
            _buildInfoCard('Contact Information', [
              if (tutor.personalInfo.phone.isNotEmpty)
                _buildInfoRow('Phone', tutor.personalInfo.phone),
              if (tutor.personalInfo.email.isNotEmpty)
                _buildInfoRow('Email', tutor.personalInfo.email),
              _buildInfoRow('Location', '${tutor.location.area}, ${tutor.location.city}'),
            ]),

            const SizedBox(height: 16),

            _buildInfoCard('Professional Information', [
              _buildInfoRow('Experience', '${tutor.professionalInfo.experience} years'),
              _buildInfoRow('Monthly Rate', '₹${tutor.professionalInfo.monthlyRate.toInt()}'),
              _buildInfoRow('Subjects', tutor.professionalInfo.subjects.join(', ')),
              _buildInfoRow('Standards', tutor.availability.standards.map((s) => '${s}th').join(', ')),
            ]),

            const SizedBox(height: 16),

            if (tutor.bio.isNotEmpty)
              _buildInfoCard('About', [
                Text(tutor.bio, style: const TextStyle(fontSize: 16)),
              ]),
              
            // Show qualification document if available
            if (tutor.professionalInfo.qualificationImageUrl.isNotEmpty)
              const SizedBox(height: 16),
            if (tutor.professionalInfo.qualificationImageUrl.isNotEmpty)
              _buildInfoCard('Qualification Document', [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: tutor.professionalInfo.qualificationImageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
