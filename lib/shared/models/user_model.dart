class UserModel {
  final String phoneNumber;
  final String? token;
  final bool isAuthenticated;

  UserModel({
    required this.phoneNumber,
    this.token,
    this.isAuthenticated = false,
  });

  // Pour transformer la réponse JSON du Backend en objet Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phone_number'] ?? '',
      token: json['token'],
      isAuthenticated: json['token'] != null,
    );
  }

  // Pour vider l'utilisateur à la déconnexion
  factory UserModel.empty() => UserModel(phoneNumber: '', isAuthenticated: false);
}