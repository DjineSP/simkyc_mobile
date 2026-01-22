class UserModel {
  final String login;
  final String? token;
  final bool isAuthenticated;

  UserModel({
    required this.login,
    this.token,
    this.isAuthenticated = false,
  });

  // Pour transformer la réponse JSON du Backend en objet Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      login: json['login'] ?? '',
      token: json['token'],
      isAuthenticated: json['token'] != null,
    );
  }

  // Pour vider l'utilisateur à la déconnexion
  factory UserModel.empty() => UserModel(login: '', isAuthenticated: false);
}