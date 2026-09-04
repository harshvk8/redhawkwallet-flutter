import 'package:cloud_firestore/cloud_firestore.dart';

class UserRole {
  static const String normalUser = 'normal_user';
  static const String verifiedStudent = 'verified_student';
  static const String vendor = 'vendor';
  static const String admin = 'admin';
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isEmailVerified;
  final bool isUniversityVerified;
  final String? universityEmail;
  final String accountStatus;
  final String? vendorStatus;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.isUniversityVerified,
    this.universityEmail,
    this.accountStatus = 'active',
    this.vendorStatus,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: (data['role'] as String?)?.trim() ?? UserRole.normalUser,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      isUniversityVerified: data['isUniversityVerified'] as bool? ?? false,
      universityEmail: data['universityEmail'] as String?,
      accountStatus: (data['accountStatus'] as String?)?.trim() ?? 'active',
      vendorStatus: (data['vendorStatus'] as String?)?.trim(),
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'isEmailVerified': isEmailVerified,
        'isUniversityVerified': isUniversityVerified,
        'universityEmail': universityEmail,
        'accountStatus': accountStatus,
        'vendorStatus': vendorStatus,
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? isEmailVerified,
    bool? isUniversityVerified,
    String? universityEmail,
    String? accountStatus,
    String? vendorStatus,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isUniversityVerified: isUniversityVerified ?? this.isUniversityVerified,
        universityEmail: universityEmail ?? this.universityEmail,
        accountStatus: accountStatus ?? this.accountStatus,
        vendorStatus: vendorStatus ?? this.vendorStatus,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
