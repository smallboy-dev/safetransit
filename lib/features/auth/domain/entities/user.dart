import 'package:equatable/equatable.dart';

enum UserType {
  passenger,
  driver,
  admin,
}

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final UserType userType;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? vehicleInfo;
  final double rating;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.lastActiveAt,
    this.location,
    this.vehicleInfo,
    this.rating = 0.0,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    UserType? userType,
    String? profileImageUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? location,
    Map<String, dynamic>? vehicleInfo,
    double? rating,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      location: location ?? this.location,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'userType': userType.name,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'location': location,
      'vehicleInfo': vehicleInfo,
      'rating': rating,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      userType: UserType.values.firstWhere(
        (type) => type.name == map['userType'] || type.toString() == map['userType'],
        orElse: () => UserType.passenger,
      ),
      profileImageUrl: map['profileImageUrl'],
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActiveAt: DateTime.parse(map['lastActiveAt'] ?? DateTime.now().toIso8601String()),
      location: map['location'],
      vehicleInfo: map['vehicleInfo'],
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phoneNumber,
        userType,
        profileImageUrl,
        isVerified,
        isActive,
        createdAt,
        lastActiveAt,
        location,
        vehicleInfo,
        rating,
      ];
}
