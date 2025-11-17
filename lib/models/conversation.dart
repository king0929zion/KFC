/// 会话模型
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final String workspacePath;
  final String historyPath;
  final String? lastMessage;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.workspacePath,
    required this.historyPath,
    this.lastMessage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messageCount': messageCount,
        'workspacePath': workspacePath,
        'historyPath': historyPath,
        'lastMessage': lastMessage,
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'],
        title: json['title'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        messageCount: json['messageCount'] ?? 0,
        workspacePath: json['workspacePath'],
        historyPath: json['historyPath'],
        lastMessage: json['lastMessage'],
      );

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    String? workspacePath,
    String? historyPath,
    String? lastMessage,
  }) =>
      Conversation(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        messageCount: messageCount ?? this.messageCount,
        workspacePath: workspacePath ?? this.workspacePath,
        historyPath: historyPath ?? this.historyPath,
        lastMessage: lastMessage ?? this.lastMessage,
      );
}
