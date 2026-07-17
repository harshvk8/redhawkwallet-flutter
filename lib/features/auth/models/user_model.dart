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
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? UserRole.normalUser,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      isUniversityVerified: data['isUniversityVerified'] as bool? ?? false,
      universityEmail: data['universityEmail'] as String?,
      accountStatus: data['accountStatus'] as String? ?? 'active',
      vendorStatus: data['vendorStatus'] as String?,
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
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
