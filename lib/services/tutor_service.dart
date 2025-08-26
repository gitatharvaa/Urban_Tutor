import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tutor_model.dart';
import 'package:urban_tutor/services/cloudinary_service.dart';

class TutorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add new tutor profile (without image uploads)
  Future<String> addTutorProfile(TutorModel t) async {
    final doc = await _firestore.collection('tutors').add(t.toFirestore());
    return doc.id;
  }

  // Get all tutors
  Stream<List<TutorModel>> getAllTutors() {
    return _firestore
        .collection('tutors')
        .where('metadata.isActive', isEqualTo: true)
        .orderBy('metadata.createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TutorModel.fromFirestore(doc)).toList());
  }

  // Get tutors by current user
  Stream<List<TutorModel>> getUserTutors() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('tutors')
        .where('metadata.userId', isEqualTo: user.uid)
        .where('metadata.isActive', isEqualTo: true)
        .orderBy('metadata.createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TutorModel.fromFirestore(doc)).toList());
  }

  // Update tutor profile
  Future<void> updateTutorProfile(String tutorId, TutorModel tutor) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user owns this profile
      DocumentSnapshot doc =
          await _firestore.collection('tutors').doc(tutorId).get();
      if (!doc.exists) throw Exception('Tutor profile not found');

      TutorModel existingTutor = TutorModel.fromFirestore(doc);
      if (existingTutor.metadata.userId != user.uid) {
        throw Exception('Unauthorized to update this profile');
      }

      // Update with new timestamp
      final updatedTutor = TutorModel(
        id: tutorId,
        personalInfo: tutor.personalInfo,
        professionalInfo: tutor.professionalInfo,
        availability: tutor.availability,
        location: tutor.location,
        socialMedia: tutor.socialMedia,
        ratings: tutor.ratings,
        metadata: MetadataInfo(
          userId: user.uid,
          createdAt: existingTutor.metadata.createdAt,
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        bio: tutor.bio,
      );

      await _firestore
          .collection('tutors')
          .doc(tutorId)
          .update(updatedTutor.toFirestore());
    } catch (e) {
      throw Exception('Failed to update tutor profile: ${e.toString()}');
    }
  }

  // Delete tutor profile (soft delete)
  Future<void> deleteTutorProfile(String tutorId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('tutors').doc(tutorId).update({
        'metadata.isActive': false,
        'metadata.updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete tutor profile: ${e.toString()}');
    }
  }

  // Search tutors (unchanged)
  Future<List<TutorModel>> searchTutors({
    String? query,
    List<String>? subjects,
    String? location,
    double? maxRate,
    double? minRating,
  }) async {
    try {
      Query tutorsQuery = _firestore
          .collection('tutors')
          .where('metadata.isActive', isEqualTo: true);

      // Apply filters
      if (location != null && location.isNotEmpty) {
        tutorsQuery = tutorsQuery.where('location.city', isEqualTo: location);
      }

      if (maxRate != null) {
        tutorsQuery = tutorsQuery.where('professionalInfo.monthlyRate',
            isLessThanOrEqualTo: maxRate);
      }

      if (minRating != null) {
        tutorsQuery = tutorsQuery.where('ratings.averageRating',
            isGreaterThanOrEqualTo: minRating);
      }

      QuerySnapshot snapshot = await tutorsQuery.get();
      List<TutorModel> tutors =
          snapshot.docs.map((doc) => TutorModel.fromFirestore(doc)).toList();

      // Apply text search and subject filters locally
      if (query != null && query.isNotEmpty) {
        tutors = tutors.where((tutor) {
          return tutor.personalInfo.fullName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              tutor.professionalInfo.qualification
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              tutor.location.city.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      if (subjects != null && subjects.isNotEmpty) {
        tutors = tutors.where((tutor) {
          return subjects.any(
              (subject) => tutor.professionalInfo.subjects.contains(subject));
        }).toList();
      }

      return tutors;
    } catch (e) {
      throw Exception('Failed to search tutors: ${e.toString()}');
    }
  }
}
