class User {
  final int id;
  final String namaLengkap;
  final String email;

  User({
    required this.id,
    required this.namaLengkap,
    required this.email,
  });

  // Factory constructor untuk membuat instance User dari map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()), // Konversi ke int dengan aman
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
    );
  }
}