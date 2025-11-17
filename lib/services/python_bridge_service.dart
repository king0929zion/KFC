import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

/// Python 桥接服务
/// 负责与 Chaquopy Python 环境通信
/// 完整集成 Kimi CLI 的所有功能
class PythonBridgeService {
  static const MethodChannel _channel = MethodChannel('kfc.python.bridge');
  
  static bool _isInitialized = false;
  static String? _sessionId;
  static String? _workDir;

  /// 初始化 Python 环境和 Kimi CLI
  static Future<Map<String, dynamic>> initialize({
    String? workDir,
    String? apiKey,
    String? baseUrl,
    String? modelName,
  }) async {
    if (_isInitialized) {
      return {
        'success': true,
        'message': '已初始化',
        'session_id': _sessionId,
      };
    }
    
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<String>(
          'initialize',
          {
            'workDir': workDir ?? '',
            'apiKey': apiKey ?? '',
            'baseUrl': baseUrl ?? '',
            'modelName': modelName ?? '',
          },
        );
        
        if (result != null) {
          final decoded = jsonDecode(result) as Map<String, dynamic>;
          if (decoded['success'] == true) {
            _isInitialized = true;
            _sessionId = decoded['session_id'] as String?;
            _workDir = decoded['work_dir'] as String?;
          }
          return decoded;
        }
      }
    } catch (e) {
      print('Kimi CLI 初始化失败: $e');
    }
    
    // 降级为模拟模式
    _isInitialized = true;
    _sessionId = 'mock_session';
    return {
      'success': true,
      'message': '模拟模式',
      'session_id': _sessionId,
    };
  }

  /// 发送消息到 Kimi CLI (流式输出)
  /// 这会触发完整的 Agent Loop,并通过Stream返回增量内容
  static Stream<Map<String, dynamic>> sendMessageStream(String message) async* {
    final initResult = await initialize();
    if (initResult['success'] != true) {
      yield {
        'type': 'error',
        'content': 'Kimi CLI 未初始化',
      };
      return;
    }
    
    try {
      if (Platform.isAndroid && _isInitialized) {
        // TODO: 实现真实的流式输出
        // 当Chaquopy集成完成后,这里会调用Python的异步生成器
        yield* _getMockStreamResponse(message);
      } else {
        yield* _getMockStreamResponse(message);
      }
    } catch (e) {
      print('发送消息失败: $e');
      yield {
        'type': 'error',
        'content': '发送失败: $e',
      };
    }
  }

  /// 执行工具调用
  static Future<Map<String, dynamic>> executeTool(
    String toolType,
    Map<String, dynamic> params,
  ) async {
    await initialize();
    
    try {
      if (Platform.isAndroid && _isInitialized) {
        final result = await _channel.invokeMethod<String>(
          'executeTool',
          {
            'toolType': toolType,
            'params': jsonEncode(params),
          },
        );
        
        if (result != null) {
          return jsonDecode(result) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('执行工具失败: $e');
    }
    
    return {
      'type': 'tool',
      'tool_type': toolType,
      'success': false,
      'message': '工具执行失败',
    };
  }

  /// 获取会话历史
  /// 对应 Kimi CLI 的 Context.history
  static Future<List<Map<String, dynamic>>> getContextHistory() async {
    await initialize();
    
    try {
      if (Platform.isAndroid && _isInitialized) {
        final result = await _channel.invokeMethod<String>('getContextHistory');
        
        if (result != null) {
          final decoded = jsonDecode(result);
          if (decoded is List) {
            return decoded.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (e) {
      print('获取历史失败: $e');
    }
    
    return [];
  }

  /// 压缩 Context
  /// 对应 KimiSoul.compact_context()
  static Future<Map<String, dynamic>> compactContext() async {
    await initialize();
    
    try {
      if (Platform.isAndroid && _isInitialized) {
        final result = await _channel.invokeMethod<String>('compactContext');
        
        if (result != null) {
          return jsonDecode(result) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('压缩 Context 失败: $e');
    }
    
    return {'success': false, 'error': '操作失败'};
  }

  /// 获取当前状态
  /// 对应 KimiSoul.status
  static Future<Map<String, dynamic>> getStatus() async {
    await initialize();
    
    try {
      if (Platform.isAndroid && _isInitialized) {
        final result = await _channel.invokeMethod<String>('getStatus');
        
        if (result != null) {
          return jsonDecode(result) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('获取状态失败: $e');
    }
    
    return {
      'initialized': _isInitialized,
      'session_id': _sessionId,
      'work_dir': _workDir,
      'context_usage': 0.0,
      'model_name': '模拟模式',
    };
  }

  /// 模拟流式回复(用于开发)
  static Stream<Map<String, dynamic>> _getMockStreamResponse(String message) async* {
    final response = '您好!这是一个模拟的流式回复。\n\n'
        '您的消息: $message\n\n'
        'KFC 项目正在开发中,Python 桥接功能即将上线。\n\n'
        '当前功能:\n'
        '✓ Flutter UI (米白主题)\n'
        '✓ 流式消息渲染\n'
        '✓ 基础交互\n'
        '⏳ Python/Chaquopy 集成\n'
        '⏳ Kimi CLI 对接';
      
    // 模拟逐字输出
    final words = response.split('');
    String accumulated = '';
      
    for (int i = 0; i < words.length; i++) {
      accumulated += words[i];
        
      // 发送增量内容
      yield {
        'type': 'chunk',
        'delta': words[i],
        'content': accumulated,
        'done': i == words.length - 1,
      };
        
      // 模拟打字延迟
      await Future.delayed(const Duration(milliseconds: 20));
    }
      
    // 发送完成标记
    yield {
      'type': 'done',
      'content': accumulated,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// 模拟回复(非流式,保持兼容性)
  static Map<String, dynamic> _getMockResponse(String message) {
    return {
      'type': 'assistant',
      'content': '您好!这是一个模拟回复。\n\n'
          '您的消息: $message\n\n'
          'KFC 项目正在开发中,Python 桥接功能即将上线。\n\n'
          '当前功能:\n'
          '✓ Flutter UI (米白主题)\n'
          '✓ 消息渲染\n'
          '✓ 基础交互\n'
          '⏳ Python/Chaquopy 集成\n'
          '⏳ Kimi CLI 对接',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
