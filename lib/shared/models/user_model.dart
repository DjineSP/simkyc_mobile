class UserModel {
  final UserData? userData;
  final TokenData? tokenData;
  final bool isAuthenticated;

  UserModel({
    this.userData,
    this.tokenData,
    this.isAuthenticated = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // L'API renvoie souvent { "success": true, "data": { "user_Data": ..., "token_Data": ... } }
    // On doit donc vérifier si les données sont à la racine ou dans 'data'
    final source = (json['data'] is Map<String, dynamic>) ? json['data'] : json;

    return UserModel(
      userData: source['user_Data'] != null ? UserData.fromJson(source['user_Data']) : null,
      tokenData: source['token_Data'] != null ? TokenData.fromJson(source['token_Data']) : null,
      isAuthenticated: true,
    );
  }

  factory UserModel.empty() => UserModel(isAuthenticated: false);
  
  // Helper to get login easily if needed by legacy code, though it should be updated
  String get login => userData?.username ?? '';

  UserModel copyWith({
    UserData? userData,
    TokenData? tokenData,
    bool? isAuthenticated,
  }) {
    return UserModel(
      userData: userData ?? this.userData,
      tokenData: tokenData ?? this.tokenData,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class UserData {
  final String idUser;
  final String username;
  final int nombreActivation;
  final int nombreReactivation;
  final int nombreMiseAJour;

  UserData({
    required this.idUser,
    required this.username,
    required this.nombreActivation,
    required this.nombreReactivation,
    required this.nombreMiseAJour,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      idUser: json['iD_User']?.toString() ?? '',
      username: json['username'] ?? '',
      nombreActivation: json['nombre_Activation'] ?? 0,
      nombreReactivation: json['nombre_Reactivation'] ?? 0,
      nombreMiseAJour: json['nombre_Mise_A_Jour'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iD_User': idUser,
      'username': username,
      'nombre_Activation': nombreActivation,
      'nombre_Reactivation': nombreReactivation,
      'nombre_Mise_A_Jour': nombreMiseAJour,
    };
  }

  UserData copyWith({
    String? idUser,
    String? username,
    int? nombreActivation,
    int? nombreReactivation,
    int? nombreMiseAJour,
  }) {
    return UserData(
      idUser: idUser ?? this.idUser,
      username: username ?? this.username,
      nombreActivation: nombreActivation ?? this.nombreActivation,
      nombreReactivation: nombreReactivation ?? this.nombreReactivation,
      nombreMiseAJour: nombreMiseAJour ?? this.nombreMiseAJour,
    );
  }
}

class TokenData {
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpiresAt;
  final String refreshTokenExpiresAt;
  final String tokenType;

  TokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.tokenType,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt'] ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt,
      'refreshTokenExpiresAt': refreshTokenExpiresAt,
      'tokenType': tokenType,
    };
  }
}