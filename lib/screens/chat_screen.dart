import 'dart:ui';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Message> _messages = [];
  final PermissionService _permissionService = PermissionService();
  final DatabaseService _dbService = DatabaseService();
  final FocusNode _inputFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _currentConversationId;
  StreamMessage? _streamingMessage; // 当前流式消息
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initConversation();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
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
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
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
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // 主内容区
          Column(
            children: [
              // 自定义顶部栏
              _buildCustomAppBar(),
              
              // 消息列表
              Expanded(
                child: _messages.isEmpty
                    ? EmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: '开始对话',
                        subtitle: '试试问我任何问题',
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
                        padding: const EdgeInsets.only(top: 16, bottom: 100, left: 8, right: 8),
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
            ],
          ),
          
          // 输入框悬浮在底部
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingInputArea(),
          ),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ActionChip(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// 自定义顶部栏
  Widget _buildCustomAppBar() {
    // 计算渐变透明度，最多滚动100像素就完全透明
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);
    
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 4,
        right: 16,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBackground.withOpacity(opacity),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withOpacity(opacity),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 三条杠菜单按钮
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: '菜单',
          ),
          
          // KFC 文字
          const SizedBox(width: 4),
          const Text(
            'KFC',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          
          const Spacer(),
          
          // 新建对话按钮
          IconButton(
            icon: const Icon(Icons.edit_note_outlined, size: 24),
            onPressed: _newConversation,
            tooltip: '新建对话',
          ),
        ],
      ),
    );
  }
  
  /// 新建对话
  void _newConversation() {
    setState(() {
      _messages.clear();
      _streamingMessage = null;
      _isLoading = false;
    });
    _initConversation();
  }
  
  /// 侧边栏抽屉
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // 头部
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.accentColor,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '历史记录',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // 历史记录列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.history, size: 20),
                  title: const Text('今天'),
                  dense: true,
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline, size: 20),
                  title: const Text('新会话'),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    _newConversation();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.folder_outlined, size: 20),
                  title: const Text('查看全部历史'),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
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
                ),
              ],
            ),
          ),
          
          // 底部设置按钮
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('设置'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
  
  /// 悬浮输入框
  Widget _buildFloatingInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 附件按钮
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showAttachmentMenu,
                      borderRadius: BorderRadius.circular(10),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // 输入框
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _inputFocusNode,
                      decoration: const InputDecoration(
                        hintText: '输入消息...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // 圆角方形发送按钮
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _isLoading || _messageController.text.isEmpty
                        ? AppTheme.dividerColor
                        : AppTheme.accentColor,
                    boxShadow: _messageController.text.isNotEmpty && !_isLoading
                        ? [
                            BoxShadow(
                              color: AppTheme.accentColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading || _messageController.text.isEmpty 
                          ? null 
                          : _sendMessage,
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(
                        _isLoading ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 附件菜单
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // 选项列表
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppTheme.accentColor,
                  ),
                ),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  _pickCamera();
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppTheme.accentColor,
                  ),
                ),
                title: const Text('图片'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insert_drive_file_outlined,
                    color: AppTheme.accentColor,
                  ),
                ),
                title: const Text('文件'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 拍照
  Future<void> _pickCamera() async {
    // TODO: 实现相机拍照
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('相机功能待实现')),
    );
  }
  
  /// 选择图片
  Future<void> _pickImage() async {
    // TODO: 实现图片选择
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片选择功能待实现')),
    );
  }
  
  /// 选择文件
  Future<void> _pickFile() async {
    // TODO: 实现文件选择
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文件选择功能待实现')),
    );
  }
}
