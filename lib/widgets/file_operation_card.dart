import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'dart:io';

/// 文件操作可视化卡片
class FileOperationCard extends StatelessWidget {
  final String operationType; // read, write, edit, delete
  final String filePath;
  final String? content;
  final int? lineCount;
  final bool isSuccess;

  const FileOperationCard({
    super.key,
    required this.operationType,
    required this.filePath,
    this.content,
    this.lineCount,
    this.isSuccess = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? AppTheme.accentColor : AppTheme.errorText,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildOperationIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getOperationTitle(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFileName(),
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
              if (lineCount != null)
                Chip(
                  label: Text(
                    '$lineCount 行',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.accentColor),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          
          if (content != null && content!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.codeBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content!.length > 500
                    ? '${content!.substring(0, 500)}...'
                    : content!,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperationIcon() {
    IconData icon;
    Color color;

    switch (operationType) {
      case 'read':
        icon = Icons.visibility;
        color = const Color(0xFF1976D2);
        break;
      case 'write':
        icon = Icons.edit;
        color = const Color(0xFF388E3C);
        break;
      case 'edit':
        icon = Icons.edit_note;
        color = const Color(0xFFF57C00);
        break;
      case 'delete':
        icon = Icons.delete;
        color = AppTheme.errorText;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = AppTheme.accentColor;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _getOperationTitle() {
    switch (operationType) {
      case 'read':
        return '读取文件';
      case 'write':
        return '写入文件';
      case 'edit':
        return '编辑文件';
      case 'delete':
        return '删除文件';
      default:
        return '文件操作';
    }
  }

  String _getFileName() {
    try {
      return filePath.split(Platform.pathSeparator).last;
    } catch (e) {
      return filePath;
    }
  }
}
