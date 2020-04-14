class ResMessage {
  String msg;

  ResMessage({this.msg});

  factory ResMessage.fromJson(Map<String, dynamic> json) {
    return ResMessage(msg: json['msg']);
  }
}
