import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:kfc/models/stream_message.dart';

/// 流式消息气泡组件
/// 支持实时更新内容
class StreamMessageBubble extends StatefulWidget {
  final StreamMessage message;

  const StreamMessageBubble({super.key, required this.message});

  @override
  State<StreamMessageBubble> createState() => _StreamMessageBubbleState();
}

class _StreamMessageBubbleState extends State<StreamMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI头像
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withOpacity(0.8),
                  AppTheme.accentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 18,
              color: Colors.white,
            ),
          ),
          
          // 内容区域
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 消息内容
                AnimatedBuilder(
                  animation: widget.message,
                  builder: (context, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: SelectableText(
                            widget.message.content,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        // 打字机光标
                        if (widget.message.isStreaming)
                          FadeTransition(
                            opacity: _cursorAnimation,
                            child: Container(
                              width: 2,
                              height: 20,
                              margin: const EdgeInsets.only(left: 2, top: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                
                // 流式输出指示器
                AnimatedBuilder(
                  animation: widget.message,
                  builder: (context, child) {
                    if (widget.message.isStreaming) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentColor.withOpacity(0.6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '正在输出...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (widget.message.isError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 14,
                              color: AppTheme.errorText.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '输出中断',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.errorText.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
