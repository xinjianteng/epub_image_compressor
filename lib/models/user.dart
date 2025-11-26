class User {
  // 用户名
  String? username;

  User({
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
      };

  @override
  String toString() {
    return 'User{username: $username,';
  }
}
