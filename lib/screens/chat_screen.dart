import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfc/config/theme.dart';
import 'package:kfc/models/message.dart';
import 'package:kfc/models/stream_message.dart';
import 'package:kfc/widgets/message_bubble.dart';
import 'package:kfc/widgets/stream_message_bubble.dart';
import 'package:kfc/widgets/empty_state.dart';
import 'package:kfc/services/python_bridge_service.dart';
import 'package:kfc/services/permission_service.dart';
import 'package:kfc/services/database_service.dart';
import 'package:kfc/screens/mcp_config_screen.dart';
import 'package:kfc/screens/conversation_history_screen.dart';
import 'package:kfc/screens/settings_screen.dart';

/// 聊天主界面
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final PermissionService _permissionService = PermissionService();
  final DatabaseService _dbService = DatabaseService();
  
  bool _isLoading = false;
  String? _currentConversationId;
  StreamMessage? _streamingMessage; // 当前流式消息

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    // 创建新会话
    _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    
    await _dbService.createConversation(
      Conversation(
        id: _currentConversationId!,
        title: '新会话 - ${DateTime.now().toString().substring(0, 16)}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      ),
    );
    
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.system,
      content: '欢迎使用 Kimi Flutter Client',
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMsg);
    });
    
    // 保存到数据库
    if (_currentConversationId != null) {
      _dbService.saveMessage(_currentConversationId!, welcomeMsg);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 添加用户消息
    final userMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.user,
      content: text,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    // 保存用户消息
    if (_currentConversationId != null) {
      await _dbService.saveMessage(_currentConversationId!, userMsg);
    }

    _messageController.clear();
    _scrollToBottom();

    try {
      // 创建流式消息
      final streamMsg = StreamMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.assistant,
        content: '',
        timestamp: DateTime.now(),
        status: StreamStatus.streaming,
      );
      
      setState(() {
        _streamingMessage = streamMsg;
        _isLoading = false;
      });
      
      _scrollToBottom();
      
      // 调用流式 API
      await for (final chunk in PythonBridgeService.sendMessageStream(text)) {
        if (chunk['type'] == 'chunk') {
          // 更新流式消息内容
          streamMsg.setContent(chunk['content'] as String);
          _scrollToBottom();
        } else if (chunk['type'] == 'done') {
          // 完成流式输出
          streamMsg.markComplete();
          
          // 转换为普通消息并保存
          final assistantMsg = streamMsg.toMessage();
          setState(() {
            _messages.add(assistantMsg);
            _streamingMessage = null;
          });
          
          // 保存AI回复
          if (_currentConversationId != null) {
            await _dbService.saveMessage(_currentConversationId!, assistantMsg);
          }
        } else if (chunk['type'] == 'error') {
          // 错误处理
          streamMsg.markError();
          streamMsg.setContent(chunk['content'] as String? ?? '未知错误');
          
          final errorMsg = streamMsg.toMessage();
          setState(() {
            _messages.add(Message(
              id: errorMsg.id,
              type: MessageType.error,
              content: errorMsg.content,
              timestamp: errorMsg.timestamp,
            ));
            _streamingMessage = null;
          });
        }
      }
    } catch (e) {
      // 异常处理
      if (_streamingMessage != null) {
        _streamingMessage!.markError();
      }
      
      final errorMsg = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.error,
        content: '发送失败: $e',
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(errorMsg);
        _streamingMessage = null;
        _isLoading = false;
      });
    }
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickCommand(String command) {
    switch (command) {
      case '/clear':
        _clearMessages();
        break;
      case '/setup':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const McpConfigScreen()),
        );
        break;
      case '/history':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationHistoryScreen(
              onConversationSelected: (id) {
                // TODO: 加载选中的会话
              },
            ),
          ),
        );
        break;
      case '/help':
        _showHelpDialog();
        break;
      case '/settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      default:
        _messageController.text = command;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '快捷命令',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('/setup - 配置 MCP 服务器'),
              Text('/settings - API 设置'),
              Text('/clear - 清空当前会话'),
              Text('/history - 查看会话历史'),
              Text('/help - 显示帮助信息'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
    _permissionService.clearSessionPermissions();
    _addWelcomeMessage();
  }

  /// 删除消息
  void _deleteMessage(int index) {
    setState(() {
      _messages.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已删除'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 复制消息
  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 重试发送消息
  void _retryMessage(String content) {
    _messageController.text = content;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationHistoryScreen(
                    onConversationSelected: (id) {
                      // TODO: 加载选中的会话
                    },
                  ),
                ),
              );
            },
            tooltip: '会话历史',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const McpConfigScreen()),
              );
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _messages.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: '开始对话',
                    subtitle: '试试问我任何问题,或者使用下方的快捷命令',
                    action: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildSuggestionChip('写一段Python代码'),
                        _buildSuggestionChip('分析这个项目'),
                        _buildSuggestionChip('帮我查找问题'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _messages.length + 
                        (_streamingMessage != null ? 1 : 0) + 
                        (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 显示加载指示器
                      if (_isLoading && index == _messages.length) {
                        return _buildLoadingIndicator();
                      }
                      
                      // 显示流式消息
                      if (_streamingMessage != null && 
                          index == _messages.length) {
                        return StreamMessageBubble(message: _streamingMessage!);
                      }
                      
                      // 显示普通消息
                      final msg = _messages[index];
                      return MessageBubble(
                        message: msg,
                        onDelete: () => _deleteMessage(index),
                        onCopy: () => _copyMessage(msg.content),
                        onRetry: msg.type == MessageType.user 
                            ? () => _retryMessage(msg.content)
                            : null,
                      );
                    },
                  ),
          ),
          
          // 快捷命令栏
          _buildQuickCommands(),
          
          // 输入框
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 加载指示器
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '正在思考...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 建议Chip
  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: AppTheme.cardBackground,
      side: const BorderSide(color: AppTheme.borderColor),
      labelStyle: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 13,
      ),
    );
  }

  /// 快捷命令栏
  Widget _buildQuickCommands() {
    final commands = [
      {'label': '/setup', 'icon': Icons.extension, 'color': Colors.purple},
      {'label': '/settings', 'icon': Icons.settings, 'color': Colors.blue},
      {'label': '/history', 'icon': Icons.history, 'color': Colors.orange},
      {'label': '/clear', 'icon': Icons.clear_all, 'color': Colors.red},
      {'label': '/help', 'icon': Icons.help_outline, 'color': Colors.green},
    ];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: commands.length,
        itemBuilder: (context, index) {
          final cmd = commands[index];
          final color = cmd['color'] as Color;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleQuickCommand(cmd['label'] as String),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cmd['icon'] as IconData, 
                        size: 18, 
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cmd['label'] as String,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.primaryBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _messageController.text.isNotEmpty 
                      ? AppTheme.accentColor.withOpacity(0.5)
                      : AppTheme.borderColor,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _sendMessage(),
                onChanged: (_) => setState(() {}), // 更新边框颜色
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: _isLoading || _messageController.text.isEmpty
                  ? null
                  : LinearGradient(
                      colors: [
                        AppTheme.accentColor,
                        AppTheme.accentColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: _isLoading || _messageController.text.isEmpty
                  ? AppTheme.dividerColor
                  : null,
              shape: BoxShape.circle,
              boxShadow: _messageController.text.isNotEmpty && !_isLoading
                  ? [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              icon: Icon(
                _isLoading ? Icons.stop_circle_outlined : Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _isLoading || _messageController.text.isEmpty 
                  ? null 
                  : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
