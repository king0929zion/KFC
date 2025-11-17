import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kfc/models/message.dart';
import 'dart:convert';

/// 数据库服务
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'kfc.db';
  static const int _dbVersion = 1;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 会话表
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 消息表
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        type INTEGER NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        tool_type INTEGER,
        metadata TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX idx_messages_conversation 
      ON messages (conversation_id, timestamp)
    ''');
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
  }

  /// 创建新会话
  Future<String> createConversation(Conversation conversation) async {
    final db = await database;
    
    await db.insert(
      'conversations',
      {
        'id': conversation.id,
        'title': conversation.title,
        'created_at': conversation.createdAt.toIso8601String(),
        'updated_at': conversation.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return conversation.id;
  }

  /// 保存消息
  Future<void> saveMessage(String conversationId, Message message) async {
    final db = await database;
    
    await db.insert(
      'messages',
      {
        'id': message.id,
        'conversation_id': conversationId,
        'type': message.type.index,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
        'tool_type': message.toolType?.index,
        'metadata': message.metadata != null 
            ? jsonEncode(message.metadata) 
            : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 更新会话的 updated_at
    await db.update(
      'conversations',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// 获取会话列表
  Future<List<Conversation>> getConversations({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    
    final results = await db.query(
      'conversations',
      orderBy: 'updated_at DESC',
      limit: limit,
      offset: offset,
    );

    final conversations = <Conversation>[];
    
    for (final row in results) {
      final messages = await getMessages(row['id'] as String);
      conversations.add(
        Conversation(
          id: row['id'] as String,
          title: row['title'] as String,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
          messages: messages,
        ),
      );
    }

    return conversations;
  }

  /// 获取会话消息
  Future<List<Message>> getMessages(String conversationId) async {
    final db = await database;
    
    final results = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );

    return results.map((row) {
      return Message(
        id: row['id'] as String,
        type: MessageType.values[row['type'] as int],
        content: row['content'] as String,
        timestamp: DateTime.parse(row['timestamp'] as String),
        toolType: row['tool_type'] != null 
            ? ToolType.values[row['tool_type'] as int]
            : null,
        metadata: row['metadata'] != null
            ? jsonDecode(row['metadata'] as String) as Map<String, dynamic>
            : null,
      );
    }).toList();
  }

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    final db = await database;
    
    await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [conversationId],
    );
    
    // 级联删除消息
    await db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  /// 更新会话标题
  Future<void> updateConversationTitle(
    String conversationId,
    String newTitle,
  ) async {
    final db = await database;
    
    await db.update(
      'conversations',
      {
        'title': newTitle,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// 清空所有数据
  Future<void> clearAll() async {
    final db = await database;
    
    await db.delete('messages');
    await db.delete('conversations');
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
