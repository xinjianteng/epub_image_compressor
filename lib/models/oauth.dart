// 登录返回
class Oauth {
  String? access_token;
  String? token_type;
  String? refresh_token;
  int? expires_in;
  String? scope;
  String? mobile;
  String? license;
  bool? active;
  String? user_id;
  String? username;

  Oauth({
    this.access_token,
    this.token_type,
    this.refresh_token,
    this.expires_in,
    this.scope,
    this.mobile,
    this.license,
    this.active,
    this.user_id,
    this.username,
  });

  factory Oauth.fromJson(Map<String, dynamic> json) => Oauth(
        access_token: json["access_token"],
        token_type: json["token_type"],
        refresh_token: json["refresh_token"],
        expires_in: json["expires_in"],
        scope: json["scope"],
        mobile: json["mobile"],
        license: json["license"],
        active: json["active"],
        user_id: json["user_id"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": access_token,
        "token_type": token_type,
        "refresh_token": refresh_token,
        "expires_in": expires_in,
        "scope": scope,
        "mobile": mobile,
        "license": license,
        "active": active,
        "user_id": user_id,
        "username": username,
      };
}
