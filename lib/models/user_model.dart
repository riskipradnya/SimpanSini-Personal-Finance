class User {
  final int id;
  final String namaLengkap;
  final String email;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.namaLengkap,
    required this.email,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat instance User dari map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()), // Konversi ke int dengan aman
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Add convenience getters
  String get name => namaLengkap;

  // Add copyWith method
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      namaLengkap: name ?? this.namaLengkap,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
