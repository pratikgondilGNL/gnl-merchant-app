class TokenData {
  final String accessToken;
  final String? refreshToken;

  const TokenData({
    required this.accessToken,
    this.refreshToken,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access'] ?? json['access_token'] ?? json['token'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('Access token not found in response');
    }

    final refreshToken = json['refresh'] ?? json['refresh_token'];

    return TokenData(
      accessToken: accessToken,
      refreshToken: refreshToken is String && refreshToken.isNotEmpty
          ? refreshToken
          : null,
    );
  }
}
