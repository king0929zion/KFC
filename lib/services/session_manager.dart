import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:kfc/models/conversation.dart';

/// 会话管理服务
/// 每个对话在独立的文件夹中运行,实现沙箱隔离
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? _currentSessionId;
  Directory? _sessionsBaseDir;

  /// 初始化会话管理器
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _sessionsBaseDir = Directory('${appDir.path}/sessions');
    await _sessionsBaseDir!.create(recursive: true);
  }

  /// 创建新会话
  Future<Conversation> createSession({String? title}) async {
    if (_sessionsBaseDir == null) {
      await initialize();
    }

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final sessionDir = Directory('${_sessionsBaseDir!.path}/$sessionId');
    await sessionDir.create(recursive: true);

    // 创建沙箱工作目录
    final workspaceDir = Directory('${sessionDir.path}/workspace');
    await workspaceDir.create();

    // 创建历史记录文件
    final historyFile = File('${sessionDir.path}/history.jsonl');
    await historyFile.create();

    // 创建元数据
    final metadata = Conversation(
      id: sessionId,
      title: title ?? '新对话',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messageCount: 0,
      workspacePath: workspaceDir.path,
      historyPath: historyFile.path,
    );

    await _saveMetadata(metadata);
    _currentSessionId = sessionId;

    return metadata;
  }

  /// 继续已有会话
  Future<Conversation?> continueSession(String sessionId) async {
    if (_sessionsBaseDir == null) {
      await initialize();
    }

    final metadataFile = File('${_sessionsBaseDir!.path}/$sessionId/metadata.json');
    if (!await metadataFile.exists()) {
      return null;
    }

    final json = jsonDecode(await metadataFile.readAsString());
    _currentSessionId = sessionId;
    return Conversation.fromJson(json);
  }

  /// 获取所有会话列表
  Future<List<Conversation>> getAllSessions() async {
    if (_sessionsBaseDir == null) {
      await initialize();
    }

    final sessions = <Conversation>[];
    final dirs = _sessionsBaseDir!.listSync().whereType<Directory>();

    for (final dir in dirs) {
      final metadataFile = File('${dir.path}/metadata.json');
      if (await metadataFile.exists()) {
        try {
          final json = jsonDecode(await metadataFile.readAsString());
          sessions.add(Conversation.fromJson(json));
        } catch (e) {
          print('Failed to load session metadata: $e');
        }
      }
    }

    // 按更新时间倒序排列
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  /// 删除会话
  Future<void> deleteSession(String sessionId) async {
    final sessionDir = Directory('${_sessionsBaseDir!.path}/$sessionId');
    if (await sessionDir.exists()) {
      await sessionDir.delete(recursive: true);
    }

    if (_currentSessionId == sessionId) {
      _currentSessionId = null;
    }
  }

  /// 更新会话元数据
  Future<void> updateSession(Conversation conversation) async {
    await _saveMetadata(conversation.copyWith(updatedAt: DateTime.now()));
  }

  /// 获取当前会话ID
  String? get currentSessionId => _currentSessionId;

  /// 获取当前会话的工作目录
  String? getCurrentWorkspace() {
    if (_currentSessionId == null) return null;
    return '${_sessionsBaseDir!.path}/$_currentSessionId/workspace';
  }

  /// 保存元数据
  Future<void> _saveMetadata(Conversation conversation) async {
    final metadataFile = File('${_sessionsBaseDir!.path}/${conversation.id}/metadata.json');
    await metadataFile.writeAsString(
      jsonEncode(conversation.toJson()),
    );
  }

  /// 清理旧会话(保留最近N个)
  Future<void> cleanupOldSessions({int keepCount = 50}) async {
    final sessions = await getAllSessions();
    if (sessions.length <= keepCount) return;

    final toDelete = sessions.skip(keepCount);
    for (final session in toDelete) {
      await deleteSession(session.id);
    }
  }
}
