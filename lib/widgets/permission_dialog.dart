import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';

/// 权限选择枚举
enum PermissionChoice {
  allowOnce,      // 允许一次
  allowSession,   // 总是允许(此会话)
  deny,           // 拒绝
}

/// 文件操作权限请求对话框
class PermissionDialog extends StatelessWidget {
  final String title;
  final String filePath;
  final String operationType;
  final String? description;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.filePath,
    required this.operationType,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 操作类型
            _buildInfoRow(
              icon: Icons.build_outlined,
              label: '操作类型',
              value: operationType,
            ),
            
            const SizedBox(height: 12),
            
            // 文件路径
            _buildInfoRow(
              icon: Icons.folder_outlined,
              label: '文件路径',
              value: filePath,
              isPath: true,
            ),
            
            if (description != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.info_outline,
                label: '说明',
                value: description!,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // 危险提示
            if (_isDangerousOperation(operationType))
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorText.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorText,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '此操作可能存在风险,请谨慎选择',
                        style: TextStyle(
                          color: AppTheme.errorText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 操作按钮
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 允许一次
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(PermissionChoice.allowOnce);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('允许一次'),
                ),
                
                const SizedBox(height: 10),
                
                // 总是允许(此会话)
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(PermissionChoice.allowSession);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.accentColor),
                    foregroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('总是允许(此会话)'),
                ),
                
                const SizedBox(height: 10),
                
                // 拒绝
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(PermissionChoice.deny);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('拒绝'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPath = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontFamily: isPath ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isDangerousOperation(String operation) {
    final dangerous = ['删除', 'delete', 'rm', '格式化', 'format'];
    return dangerous.any((word) => 
      operation.toLowerCase().contains(word.toLowerCase())
    );
  }

  /// 显示权限对话框
  static Future<PermissionChoice?> show(
    BuildContext context, {
    required String title,
    required String filePath,
    required String operationType,
    String? description,
  }) {
    return showDialog<PermissionChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: title,
        filePath: filePath,
        operationType: operationType,
        description: description,
      ),
    );
  }
}
