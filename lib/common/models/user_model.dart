class UserModel {
  final String userId;
  final String username;
  final String title;
  final String firstName;
  final String lastName;
  final String profile;
  final String groupId;
  final String groupName;
  final String siteUrl;
  final String college;

  const UserModel({
    required this.userId,
    required this.username,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.profile,
    required this.groupId,
    required this.groupName,
    required this.siteUrl,
    required this.college,
  });

  String get fullName => '$title. $firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['userid'] ?? '',
        username: json['username'] ?? '',
        title: json['title'] ?? '',
        firstName: json['firstname'] ?? '',
        lastName: json['lastname'] ?? '',
        profile: json['profile'] ?? '',
        groupId: json['groupid'] ?? '',
        groupName: json['groupname'] ?? '',
        siteUrl: json['site_url'] ?? '',
        college: json['college'] ?? '',
      );

  factory UserModel.fromPipeDelimited(List<String> parts) => UserModel(
        userId: parts[0],
        username: parts[1],
        title: parts[2],
        firstName: parts[3],
        lastName: parts[4],
        profile: parts[5],
        groupId: parts[6],
        groupName: parts[7],
        siteUrl: parts[8],
        college: parts[9],
      );

  Map<String, dynamic> toMap() => {
        'userid': userId,
        'username': username,
        'title': title,
        'firstname': firstName,
        'lastname': lastName,
        'profile': profile,
        'groupid': groupId,
        'groupname': groupName,
        'site_url': siteUrl,
        'college': college,
      };
}
