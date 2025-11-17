import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfc/config/theme.dart';

/// Bash/CMD执行可视化卡片
class BashExecutionCard extends StatefulWidget {
  final String command;
  final String? output;
  final String? error;
  final int? exitCode;
  final bool isRunning;
  final Duration? duration;

  const BashExecutionCard({
    super.key,
    required this.command,
    this.output,
    this.error,
    this.exitCode,
    this.isRunning = false,
    this.duration,
  });

  @override
  State<BashExecutionCard> createState() => _BashExecutionCardState();
}

class _BashExecutionCardState extends State<BashExecutionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final isSuccess = widget.exitCode == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isRunning
              ? AppTheme.accentColor
              : (hasError ? AppTheme.errorText : AppTheme.successColor),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(hasError, isSuccess),
          if (_isExpanded) ...[
            const Divider(height: 1),
            _buildOutput(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(bool hasError, bool isSuccess) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(hasError, isSuccess),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bash 执行',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (widget.duration != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.duration!.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '\$ ',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: Colors.green.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.command,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: Colors.grey.shade400),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.command));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('命令已复制'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool hasError, bool isSuccess) {
    if (widget.isRunning) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (hasError ? AppTheme.errorText : AppTheme.successColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        hasError ? Icons.error : Icons.check_circle,
        color: hasError ? AppTheme.errorText : AppTheme.successColor,
        size: 22,
      ),
    );
  }

  Widget _buildOutput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.output != null && widget.output!.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  '输出',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.output!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('输出已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.output!,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ],
          
          if (widget.error != null && widget.error!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '错误',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorText.withOpacity(0.3),
                ),
              ),
              child: SelectableText(
                widget.error!,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppTheme.errorText,
                  height: 1.5,
                ),
              ),
            ),
          ],
          
          if (widget.exitCode != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Exit Code: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.exitCode == 0
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.errorText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.exitCode}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: widget.exitCode == 0
                          ? AppTheme.successColor
                          : AppTheme.errorText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
