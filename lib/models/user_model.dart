// lib/models/user_model.dart

class User {
  final int id;
  final String name;
  final String email;
  final String? profileImage; // Ini akan menyimpan path gambar
  final String password; // Ini untuk simulasi local, TIDAK AMAN untuk produksi

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['nama_lengkap'], // Sesuaikan dengan key 'nama_lengkap' dari AuthService
      email: json['email'],
      profileImage: json['profile_image'], // Asumsi key ini ada di data user
      password: json['password'], // Asumsi password ada di data (sekali lagi, TIDAK AMAN)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage, // Sesuaikan dengan key jika ada
      'password': password,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImage,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      password: password ?? this.password,
    );
  }
}