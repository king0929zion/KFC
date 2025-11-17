import 'package:flutter/material.dart';
import 'package:kfc/widgets/permission_dialog.dart';

/// 权限管理服务
/// 管理文件操作、命令执行等权限请求
class PermissionService {
  // 会话级别的权限缓存
  final Map<String, bool> _sessionPermissions = {};
  
  // 危险命令黑名单
  static final List<String> _dangerousCommands = [
    'rm -rf',
    'format',
    'mkfs',
    'dd if=',
    ':(){:|:&};:',  // fork bomb
  ];

  /// 请求文件操作权限
  Future<bool> requestFilePermission(
    BuildContext context, {
    required String filePath,
    required String operation,
    String? description,
  }) async {
    // 生成权限key
    final permissionKey = 'file:$operation:$filePath';
    
    // 检查会话级权限
    if (_sessionPermissions.containsKey(permissionKey)) {
      return _sessionPermissions[permissionKey]!;
    }
    
    // 显示权限对话框
    final choice = await PermissionDialog.show(
      context,
      title: '文件操作权限请求',
      filePath: filePath,
      operationType: operation,
      description: description,
    );
    
    switch (choice) {
      case PermissionChoice.allowOnce:
        return true;
      
      case PermissionChoice.allowSession:
        _sessionPermissions[permissionKey] = true;
        return true;
      
      case PermissionChoice.deny:
      case null:
        return false;
    }
  }

  /// 请求命令执行权限
  Future<bool> requestCommandPermission(
    BuildContext context, {
    required String command,
    String? description,
  }) async {
    // 检查危险命令
    final isDangerous = _isDangerousCommand(command);
    
    final permissionKey = 'command:$command';
    
    // 危险命令每次都要询问
    if (!isDangerous && _sessionPermissions.containsKey(permissionKey)) {
      return _sessionPermissions[permissionKey]!;
    }
    
    // 显示权限对话框
    final choice = await PermissionDialog.show(
      context,
      title: isDangerous ? '⚠️ 危险命令执行请求' : '命令执行权限请求',
      filePath: command,
      operationType: 'Shell命令执行',
      description: description ?? (isDangerous ? '此命令可能对系统造成危害' : null),
    );
    
    switch (choice) {
      case PermissionChoice.allowOnce:
        return true;
      
      case PermissionChoice.allowSession:
        if (!isDangerous) {
          _sessionPermissions[permissionKey] = true;
        }
        return true;
      
      case PermissionChoice.deny:
      case null:
        return false;
    }
  }

  /// 请求MCP工具调用权限
  Future<bool> requestMcpPermission(
    BuildContext context, {
    required String toolName,
    required Map<String, dynamic> params,
  }) async {
    final permissionKey = 'mcp:$toolName';
    
    if (_sessionPermissions.containsKey(permissionKey)) {
      return _sessionPermissions[permissionKey]!;
    }
    
    final choice = await PermissionDialog.show(
      context,
      title: 'MCP工具调用请求',
      filePath: toolName,
      operationType: 'MCP工具',
      description: '参数: ${params.toString()}',
    );
    
    switch (choice) {
      case PermissionChoice.allowOnce:
        return true;
      
      case PermissionChoice.allowSession:
        _sessionPermissions[permissionKey] = true;
        return true;
      
      case PermissionChoice.deny:
      case null:
        return false;
    }
  }

  /// 清除会话权限
  void clearSessionPermissions() {
    _sessionPermissions.clear();
  }

  /// 检查是否为危险命令
  bool _isDangerousCommand(String command) {
    final lowerCommand = command.toLowerCase();
    return _dangerousCommands.any((dangerous) => 
      lowerCommand.contains(dangerous.toLowerCase())
    );
  }

  /// 获取危险命令列表
  List<String> get dangerousCommands => List.unmodifiable(_dangerousCommands);
}
