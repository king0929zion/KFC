import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';

/// Agent状态监控栏
class StatusBar extends StatelessWidget {
  final double contextUsage;
  final String? currentTool;
  final bool isProcessing;
  final VoidCallback? onCompact;

  const StatusBar({
    super.key,
    required this.contextUsage,
    this.currentTool,
    this.isProcessing = false,
    this.onCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Context使用率指示器
          _buildContextIndicator(),
          
          const SizedBox(width: 12),
          
          // 当前工具状态
          if (currentTool != null) ...[
            _buildToolStatus(),
            const Spacer(),
          ] else
            const Spacer(),
          
          // Compact按钮
          if (contextUsage > 0.7)
            _buildCompactButton(),
        ],
      ),
    );
  }

  Widget _buildContextIndicator() {
    Color indicatorColor;
    if (contextUsage < 0.6) {
      indicatorColor = AppTheme.successColor;
    } else if (contextUsage < 0.8) {
      indicatorColor = AppTheme.warningColor;
    } else {
      indicatorColor = AppTheme.errorText;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: contextUsage,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation(indicatorColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(contextUsage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildToolStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProcessing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
              ),
            )
          else
            Icon(
              Icons.build,
              size: 12,
              color: AppTheme.accentColor,
            ),
          const SizedBox(width: 4),
          Text(
            currentTool!,
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

  Widget _buildCompactButton() {
    return TextButton.icon(
      onPressed: onCompact,
      icon: Icon(
        Icons.compress,
        size: 14,
        color: AppTheme.accentColor,
      ),
      label: Text(
        '压缩',
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.accentColor,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
