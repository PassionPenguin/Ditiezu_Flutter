class User {
  int uid;
  String userName;

  User.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    userName = json["userName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['userName'] = this.userName;
    return data;
  }
}
