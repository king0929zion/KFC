import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:kfc/models/stream_message.dart';

/// 工具调用进度卡片
class ToolCallProgressCard extends StatelessWidget {
  final ToolCallProgress progress;

  const ToolCallProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 工具名称和状态
            Row(
              children: [
                Icon(
                  _getToolIcon(progress.toolName),
                  size: 20,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.toolName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        progress.action,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 详情
            if (progress.details.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.codeBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  progress.details,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            
            // 进度条
            if (!progress.isComplete && progress.error == null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.progress,
                  backgroundColor: AppTheme.dividerColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.accentColor,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            
            // 结果或错误
            if (progress.result != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        progress.result!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (progress.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.errorText.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 16,
                      color: AppTheme.errorText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        progress.error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.errorText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (progress.isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '完成',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.successColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    if (progress.error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.errorText.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '失败',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.errorText,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ),
          SizedBox(width: 6),
          Text(
            '进行中',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (progress.error != null) return AppTheme.errorText;
    if (progress.isComplete) return AppTheme.successColor;
    return AppTheme.accentColor;
  }

  IconData _getToolIcon(String toolName) {
    final lowerName = toolName.toLowerCase();
    if (lowerName.contains('file')) return Icons.description;
    if (lowerName.contains('bash') || lowerName.contains('cmd')) {
      return Icons.terminal;
    }
    if (lowerName.contains('web') || lowerName.contains('search')) {
      return Icons.search;
    }
    if (lowerName.contains('task')) return Icons.task_alt;
    return Icons.build;
  }
}
