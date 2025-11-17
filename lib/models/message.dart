/// 消息类型
enum MessageType {
  user,       // 用户消息
  assistant,  // AI 回复
  system,     // 系统消息
  tool,       // 工具调用
  error,      // 错误消息
}

/// 工具调用类型
enum ToolType {
  fileEdit,     // 文件编辑
  fileRead,     // 文件读取
  bash,         // Shell 命令
  mcpCall,      // MCP 工具调用
  codeExecute,  // 代码执行
}

/// 消息模型
class Message {
  final String id;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final ToolType? toolType;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.toolType,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      type: MessageType.values[json['type'] as int],
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      toolType: json['toolType'] != null 
          ? ToolType.values[json['toolType'] as int]
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'toolType': toolType?.index,
      'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    MessageType? type,
    String? content,
    DateTime? timestamp,
    ToolType? toolType,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      toolType: toolType ?? this.toolType,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 会话模型
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
