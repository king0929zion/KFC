import 'package:flutter/foundation.dart';
import 'package:kfc/models/message.dart';

/// 流式消息状态
enum StreamStatus {
  streaming,   // 正在流式输出
  complete,    // 完成
  error,       // 错误
}

/// 流式消息模型
/// 用于实时展示AI回复的逐字输出
class StreamMessage extends ChangeNotifier {
  final String id;
  final MessageType type;
  String _content;
  DateTime timestamp;
  StreamStatus _status;
  ToolType? toolType;
  Map<String, dynamic>? metadata;
  
  StreamMessage({
    required this.id,
    required this.type,
    String content = '',
    required this.timestamp,
    StreamStatus status = StreamStatus.streaming,
    this.toolType,
    this.metadata,
  }) : _content = content,
       _status = status;

  String get content => _content;
  StreamStatus get status => _status;
  
  bool get isStreaming => _status == StreamStatus.streaming;
  bool get isComplete => _status == StreamStatus.complete;
  bool get isError => _status == StreamStatus.error;

  /// 追加内容
  void appendContent(String delta) {
    _content += delta;
    notifyListeners();
  }

  /// 设置完整内容
  void setContent(String content) {
    _content = content;
    notifyListeners();
  }

  /// 标记为完成
  void markComplete() {
    _status = StreamStatus.complete;
    notifyListeners();
  }

  /// 标记为错误
  void markError() {
    _status = StreamStatus.error;
    notifyListeners();
  }

  /// 转换为普通消息
  Message toMessage() {
    return Message(
      id: id,
      type: type,
      content: _content,
      timestamp: timestamp,
      toolType: toolType,
      metadata: metadata,
    );
  }

  /// 从消息创建流式消息
  factory StreamMessage.fromMessage(Message message) {
    return StreamMessage(
      id: message.id,
      type: message.type,
      content: message.content,
      timestamp: message.timestamp,
      status: StreamStatus.complete,
      toolType: message.toolType,
      metadata: message.metadata,
    );
  }
}

/// 工具调用进度
class ToolCallProgress {
  final String toolName;
  final String action;
  final String details;
  double progress; // 0.0 - 1.0
  bool isComplete;
  String? result;
  String? error;

  ToolCallProgress({
    required this.toolName,
    required this.action,
    required this.details,
    this.progress = 0.0,
    this.isComplete = false,
    this.result,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'toolName': toolName,
    'action': action,
    'details': details,
    'progress': progress,
    'isComplete': isComplete,
    'result': result,
    'error': error,
  };

  factory ToolCallProgress.fromJson(Map<String, dynamic> json) {
    return ToolCallProgress(
      toolName: json['toolName'] as String,
      action: json['action'] as String,
      details: json['details'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isComplete: json['isComplete'] as bool? ?? false,
      result: json['result'] as String?,
      error: json['error'] as String?,
    );
  }
}
