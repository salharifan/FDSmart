class UserModel {
  final String uid;
  final String email;
  final String role; // 'user' or 'admin'
  final String? name;
  final List<String> favorites;
  final double tokens;
  final String? profileImageUrl;

  final String? phone;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.favorites = const [],
    this.tokens = 50.0,
    this.profileImageUrl,
    this.phone,
  });

  double get balance => tokens;

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      name: data['name'],
      favorites: List<String>.from(data['favorites'] ?? []),
      tokens: (data['tokens'] ?? 50.0).toDouble(),
      profileImageUrl: data['profileImageUrl'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'favorites': favorites,
      'tokens': tokens,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
    };
  }
}
