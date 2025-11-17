import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';

/// 工具执行权限审批对话框
class ApprovalDialog extends StatelessWidget {
  final String toolName;
  final String action;
  final String description;
  final VoidCallback onApprove;
  final VoidCallback onApproveForSession;
  final VoidCallback onReject;

  const ApprovalDialog({
    super.key,
    required this.toolName,
    required this.action,
    required this.description,
    required this.onApprove,
    required this.onApproveForSession,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '权限请求',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 工具信息
            _buildInfoRow('工具', toolName),
            const SizedBox(height: 12),
            _buildInfoRow('操作', action),
            
            const SizedBox(height: 20),
            
            // 详细描述
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderColor,
                ),
              ),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onReject();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorText,
                      side: BorderSide(color: AppTheme.errorText),
                    ),
                    child: const Text('拒绝'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onApprove();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('允许'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 本次会话始终允许
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onApproveForSession();
                },
                child: Text(
                  '本次会话始终允许',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 显示权限审批对话框
Future<ApprovalResponse?> showApprovalDialog({
  required BuildContext context,
  required String toolName,
  required String action,
  required String description,
}) {
  ApprovalResponse? result;
  
  return showDialog<ApprovalResponse>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ApprovalDialog(
      toolName: toolName,
      action: action,
      description: description,
      onApprove: () {
        result = ApprovalResponse.approve;
      },
      onApproveForSession: () {
        result = ApprovalResponse.approveForSession;
      },
      onReject: () {
        result = ApprovalResponse.reject;
      },
    ),
  ).then((_) => result ?? ApprovalResponse.reject);
}

enum ApprovalResponse {
  approve,
  approveForSession,
  reject,
}
