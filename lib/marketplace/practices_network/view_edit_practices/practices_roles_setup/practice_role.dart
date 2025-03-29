class PracticeRole {
  final String id;
  final String title;
  final List<dynamic> permissions;

  PracticeRole({
    required this.id,
    required this.title,
    required this.permissions,
  });

  factory PracticeRole.fromJson(Map<String, dynamic> json) {
    return PracticeRole(
      id: json['id'],
      title: json['title'],
      permissions: json['permissions'] ?? [],
    );
  }
}
