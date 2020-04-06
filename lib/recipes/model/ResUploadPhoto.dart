class ResUploadPhoto {
  String msg;
  String photo;

  ResUploadPhoto({this.msg, this.photo});

  factory ResUploadPhoto.fromJson(Map<String, dynamic> json) {
    return ResUploadPhoto(msg: json['id'], photo: json['tag']);
  }
}
