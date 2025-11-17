import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfc/config/theme.dart';
import 'package:kfc/models/message.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// 消息气泡组件
class MessageBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onDelete,
    this.onCopy,
    this.onRetry,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildMessageContent(context),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (widget.message.type) {
      case MessageType.user:
        return _buildUserMessage(context);
      case MessageType.assistant:
        return _buildAssistantMessage(context);
      case MessageType.tool:
        return _buildToolMessage(context);
      case MessageType.error:
        return _buildErrorMessage(context);
      case MessageType.system:
        return _buildSystemMessage(context);
    }
  }

  /// 用户消息 - 右对齐深灰文字
  Widget _buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageMenu(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.message.content,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AI消息 - 左对齐纯Markdown文本
  Widget _buildAssistantMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageMenu(context),
              child: MarkdownBody(
                data: widget.message.content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  code: const TextStyle(
                    backgroundColor: AppTheme.codeBackground,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: AppTheme.codeBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  codeblockPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 工具调用消息 - 白色卡片
  Widget _buildToolMessage(BuildContext context) {
    IconData icon;
    String title;
    
    switch (widget.message.toolType) {
      case ToolType.fileEdit:
        icon = Icons.edit_document;
        title = '文件编辑';
        break;
      case ToolType.fileRead:
        icon = Icons.description_outlined;
        title = '读取文件';
        break;
      case ToolType.bash:
        icon = Icons.terminal;
        title = '执行命令';
        break;
      case ToolType.mcpCall:
        icon = Icons.extension;
        title = 'MCP工具';
        break;
      case ToolType.codeExecute:
        icon = Icons.code;
        title = '代码执行';
        break;
      default:
        icon = Icons.build;
        title = '工具调用';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (widget.message.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildCodeBlock(widget.message.content, _detectLanguage(widget.message.content)),
              ],
              if (widget.message.metadata != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatMetadata(widget.message.metadata!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 错误消息 - 淡红色卡片
  Widget _buildErrorMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.errorText.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorText, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message.content,
                style: const TextStyle(
                  color: AppTheme.errorText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 系统消息 - 居中灰色文字
  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Text(
          widget.message.content,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    final buffer = StringBuffer();
    metadata.forEach((key, value) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('$key: $value');
    });
    return buffer.toString();
  }

  /// 构建代码块
  Widget _buildCodeBlock(String code, String language) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 语言标签
            if (language.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.dividerColor,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.code,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      language,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            // 代码内容
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: HighlightView(
                code,
                language: language.isNotEmpty ? language : 'plaintext',
                theme: githubTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 检测代码语言
  String _detectLanguage(String code) {
    // 简单的语言检测逻辑
    if (code.contains('def ') || code.contains('import ')) return 'python';
    if (code.contains('function ') || code.contains('const ') || code.contains('let ')) return 'javascript';
    if (code.contains('class ') && code.contains('{')) return 'java';
    if (code.contains('#include')) return 'cpp';
    if (code.contains('fn ') || code.contains('let mut')) return 'rust';
    if (code.contains('package ')) return 'go';
    if (RegExp(r'^\s*(ls|cd|cat|grep|echo|rm|mkdir)').hasMatch(code)) return 'bash';
    return 'plaintext';
  }

  /// 显示消息操作菜单
  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 复制
              ListTile(
                leading: const Icon(Icons.copy, color: AppTheme.accentColor),
                title: const Text('复制'),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onCopy != null) {
                    widget.onCopy!();
                  } else {
                    // 默认复制行为
                    Clipboard.setData(ClipboardData(text: widget.message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              
              // 删除
              if (widget.onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.errorText),
                  title: const Text('删除', style: TextStyle(color: AppTheme.errorText)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onDelete!();
                  },
                ),
              
              // 重试(仅用户消息或错误消息)
              if (widget.onRetry != null && 
                  (widget.message.type == MessageType.user || widget.message.type == MessageType.error))
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppTheme.accentColor),
                  title: const Text('重试'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRetry!();
                  },
                ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
