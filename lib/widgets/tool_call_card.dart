import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfc/config/theme.dart';

/// 工具调用可视化卡片
class ToolCallCard extends StatefulWidget {
  final String toolName;
  final String action;
  final Map<String, dynamic> parameters;
  final String? result;
  final bool isSuccess;
  final bool isRunning;

  const ToolCallCard({
    super.key,
    required this.toolName,
    required this.action,
    required this.parameters,
    this.result,
    this.isSuccess = true,
    this.isRunning = false,
  });

  @override
  State<ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<ToolCallCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_isExpanded) ...[
                const Divider(height: 1),
                _buildDetails(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (widget.isRunning) return AppTheme.accentColor;
    if (!widget.isSuccess) return AppTheme.errorText;
    return AppTheme.borderColor;
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getToolDisplayName(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.action,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.isRunning)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
                ),
              )
            else
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    final name = widget.toolName;
    switch (name) {
      case 'Bash':
      case 'CMD':
        iconData = Icons.terminal;
        iconColor = const Color(0xFF2E7D32);
        break;
      case 'ReadFile':
      case 'WriteFile':
      case 'StrReplaceFile':
      case 'PatchFile':
      case 'Glob':
      case 'Grep':
        iconData = Icons.description;
        iconColor = const Color(0xFF1976D2);
        break;
      case 'SearchWeb':
        iconData = Icons.search;
        iconColor = const Color(0xFFE65100);
        break;
      case 'FetchURL':
        iconData = Icons.public;
        iconColor = const Color(0xFF0277BD);
        break;
      case 'Task':
        iconData = Icons.assignment;
        iconColor = const Color(0xFF6A1B9A);
        break;
      case 'Think':
        iconData = Icons.psychology;
        iconColor = const Color(0xFFAD1457);
        break;
      default:
        iconData = Icons.extension;
        iconColor = AppTheme.accentColor;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
    );
  }

  String _getToolDisplayName() {
    switch (widget.toolName) {
      case 'Bash':
        return 'Bash 执行';
      case 'CMD':
        return 'CMD 执行';
      case 'ReadFile':
        return '读取文件';
      case 'WriteFile':
        return '写入文件';
      case 'StrReplaceFile':
        return '字符串替换';
      case 'PatchFile':
        return '补丁变更';
      case 'Glob':
        return '路径匹配';
      case 'Grep':
        return '内容搜索';
      case 'SearchWeb':
        return 'Web 搜索';
      case 'FetchURL':
        return '获取网页';
      case 'Task':
        return '任务执行';
      case 'Think':
        return '思考中';
      default:
        return widget.toolName;
    }
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 参数
          if (widget.parameters.isNotEmpty) ...[
            _buildSectionTitle('参数'),
            const SizedBox(height: 8),
            _buildParametersView(),
            const SizedBox(height: 16),
          ],
          
          // 结果
          if (widget.result != null) ...[
            _buildSectionTitle('结果'),
            const SizedBox(height: 8),
            _buildResultView(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildParametersView() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.parameters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '${entry.key}:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultView() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isSuccess
            ? AppTheme.codeBackground
            : AppTheme.errorBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isSuccess
              ? AppTheme.borderColor
              : AppTheme.errorText.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              widget.result!,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: widget.isSuccess
                    ? AppTheme.textPrimary
                    : AppTheme.errorText,
                height: 1.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.result!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已复制到剪贴板'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
