import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:kfc/models/stream_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// 流式消息气泡组件
/// 支持实时更新内容和Markdown渲染
class StreamMessageBubble extends StatelessWidget {
  final StreamMessage message;

  const StreamMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: AnimatedBuilder(
              animation: message,
              builder: (context, child) {
                return MarkdownBody(
                  data: message.content,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    code: const TextStyle(
                      backgroundColor: AppTheme.codeBackground,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: AppTheme.codeBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
