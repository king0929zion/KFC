import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:kfc/models/message.dart';
import 'package:kfc/services/database_service.dart';
import 'package:kfc/utils/date_utils.dart';

/// 会话历史列表界面
class ConversationHistoryScreen extends StatefulWidget {
  final Function(String conversationId)? onConversationSelected;

  const ConversationHistoryScreen({
    super.key,
    this.onConversationSelected,
  });

  @override
  State<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    try {
      final conversations = await _dbService.getConversations(limit: 100);
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: AppTheme.errorText,
          ),
        );
      }
    }
  }

  Future<void> _deleteConversation(String id) async {
    try {
      await _dbService.deleteConversation(id);
      await _loadConversations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已删除'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: AppTheme.errorText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会话历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildConversationList(),
    );
  }

  Widget _buildConversationList() {
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无会话记录',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        return _buildConversationCard(_conversations[index]);
      },
    );
  }

  Widget _buildConversationCard(Conversation conversation) {
    final messageCount = conversation.messages.length;
    final preview = _getConversationPreview(conversation);
    final timeAgo = DateTimeUtils.formatRelative(conversation.updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (widget.onConversationSelected != null) {
            widget.onConversationSelected!(conversation.id);
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      conversation.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _showDeleteConfirmDialog(conversation.id),
                    color: AppTheme.errorText,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (preview.isNotEmpty)
                Text(
                  preview,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$messageCount 条消息',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getConversationPreview(Conversation conversation) {
    if (conversation.messages.isEmpty) return '';

    // 获取最后一条非系统消息
    for (var i = conversation.messages.length - 1; i >= 0; i--) {
      final msg = conversation.messages[i];
      if (msg.type != MessageType.system) {
        return msg.content;
      }
    }

    return conversation.messages.last.content;
  }

  void _showDeleteConfirmDialog(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除会话'),
        content: const Text('确定要删除这个会话吗?此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(conversationId);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorText,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
