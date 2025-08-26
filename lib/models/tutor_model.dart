import 'package:cloud_firestore/cloud_firestore.dart';

class TutorModel {
  final String? id;
  final PersonalInfo personalInfo;
  final ProfessionalInfo professionalInfo;
  final AvailabilityInfo availability;
  final LocationInfo location;
  final SocialMediaInfo socialMedia;
  final RatingInfo ratings;
  final MetadataInfo metadata;
  final String bio;

  TutorModel({
    this.id,
    required this.personalInfo,
    required this.professionalInfo,
    required this.availability,
    required this.location,
    required this.socialMedia,
    required this.ratings,
    required this.metadata,
    required this.bio,
  });

  factory TutorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TutorModel(
      id: doc.id,
      personalInfo: PersonalInfo.fromMap(data['personalInfo'] ?? {}),
      professionalInfo: ProfessionalInfo.fromMap(data['professionalInfo'] ?? {}),
      availability: AvailabilityInfo.fromMap(data['availability'] ?? {}),
      location: LocationInfo.fromMap(data['location'] ?? {}),
      socialMedia: SocialMediaInfo.fromMap(data['socialMedia'] ?? {}),
      ratings: RatingInfo.fromMap(data['ratings'] ?? {}),
      metadata: MetadataInfo.fromMap(data['metadata'] ?? {}),
      bio: data['bio'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'personalInfo': personalInfo.toMap(),
      'professionalInfo': professionalInfo.toMap(),
      'availability': availability.toMap(),
      'location': location.toMap(),
      'socialMedia': socialMedia.toMap(),
      'ratings': ratings.toMap(),
      'metadata': metadata.toMap(),
      'bio': bio,
    };
  }
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String profileImageUrl; // Add back

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
  });

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class ProfessionalInfo {
  final String qualification;
  final String qualificationImageUrl; // Add back
  final int experience;
  final List<String> subjects;
  final List<String> specializations;
  final double monthlyRate;

  ProfessionalInfo({
    required this.qualification,
    required this.qualificationImageUrl,
    required this.experience,
    required this.subjects,
    required this.specializations,
    required this.monthlyRate,
  });

  factory ProfessionalInfo.fromMap(Map<String, dynamic> map) {
    return ProfessionalInfo(
      qualification: map['qualification'] ?? '',
      qualificationImageUrl: map['qualificationImageUrl'] ?? '',
      experience: map['experience']?.toInt() ?? 0,
      subjects: List<String>.from(map['subjects'] ?? []),
      specializations: List<String>.from(map['specializations'] ?? []),
      monthlyRate: map['monthlyRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qualification': qualification,
      'qualificationImageUrl': qualificationImageUrl,
      'experience': experience,
      'subjects': subjects,
      'specializations': specializations,
      'monthlyRate': monthlyRate,
    };
  }
}

class AvailabilityInfo {
  final List<int> standards;
  final Map<String, String> timeSlots;

  AvailabilityInfo({
    required this.standards,
    required this.timeSlots,
  });

  factory AvailabilityInfo.fromMap(Map<String, dynamic> map) {
    return AvailabilityInfo(
      standards: List<int>.from(map['standards'] ?? []),
      timeSlots: Map<String, String>.from(map['timeSlots'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'standards': standards,
      'timeSlots': timeSlots,
    };
  }
}

class LocationInfo {
  final String city;
  final String area;
  final String address;

  LocationInfo({
    required this.city,
    required this.area,
    required this.address,
  });

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'area': area,
      'address': address,
    };
  }
}

class SocialMediaInfo {
  final String whatsapp;
  final String facebook;
  final String instagram;
  final String twitter;

  SocialMediaInfo({
    required this.whatsapp,
    required this.facebook,
    required this.instagram,
    required this.twitter,
  });

  factory SocialMediaInfo.fromMap(Map<String, dynamic> map) {
    return SocialMediaInfo(
      whatsapp: map['whatsapp'] ?? '',
      facebook: map['facebook'] ?? '',
      instagram: map['instagram'] ?? '',
      twitter: map['twitter'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'whatsapp': whatsapp,
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
    };
  }
}

class RatingInfo {
  final double averageRating;
  final int totalReviews;

  RatingInfo({
    required this.averageRating,
    required this.totalReviews,
  });

  factory RatingInfo.fromMap(Map<String, dynamic> map) {
    return RatingInfo(
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}

class MetadataInfo {
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  MetadataInfo({
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory MetadataInfo.fromMap(Map<String, dynamic> map) {
    return MetadataInfo(
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }
}
