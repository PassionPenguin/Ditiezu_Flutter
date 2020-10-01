class User {
  int uid = 0;
  String userName = "";
  bool loginState = false;

  User({this.uid, this.userName, this.loginState});

  User.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    userName = json["userName"];
    loginState = json["loginState"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['userName'] = this.userName;
    data['loginState'] = this.loginState;
    return data;
  }
}
