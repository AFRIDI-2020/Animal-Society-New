class Animal {
  String? groupId;
  String? status;
  String? userProfileImage;
  String? username;
  String? mobile;
  String? id;
  String? photo;
  String? video;
  String? petName;
  String? color;
  String? age;
  String? gender;
  String? genus;
  String? totalComments;
  String? totalFollowings;
  String? totalShares;
  String? date;

  Animal(
      {required this.status,
      required this.groupId,
      this.userProfileImage,
      this.username,
      this.mobile,
      this.id,
      this.photo,
      this.video,
      this.petName,
      this.color,
      this.age,
      this.gender,
      this.genus,
      this.totalComments,
      this.totalFollowings,
      this.totalShares,
      this.date});
}
