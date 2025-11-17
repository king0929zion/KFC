import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// MCP服务器配置
class McpServerConfig {
  final String id;
  final String name;
  final String command;
  final List<String> args;
  bool enabled;

  McpServerConfig({
    required this.id,
    required this.name,
    required this.command,
    required this.args,
    this.enabled = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'command': command,
    'args': args,
    'enabled': enabled,
  };

  factory McpServerConfig.fromJson(Map<String, dynamic> json) => McpServerConfig(
    id: json['id'] as String,
    name: json['name'] as String,
    command: json['command'] as String,
    args: List<String>.from(json['args'] as List),
    enabled: json['enabled'] as bool? ?? false,
  );
}

/// MCP配置界面
class McpConfigScreen extends StatefulWidget {
  const McpConfigScreen({super.key});

  @override
  State<McpConfigScreen> createState() => _McpConfigScreenState();
}

class _McpConfigScreenState extends State<McpConfigScreen> {
  List<McpServerConfig> _servers = [];
  bool _isLoading = true;

  // 预设的MCP服务器
  static final List<McpServerConfig> _presetServers = [
    McpServerConfig(
      id: 'context7',
      name: 'Context7',
      command: 'npx',
      args: ['-y', '@upaya/context7'],
    ),
    McpServerConfig(
      id: 'chrome-devtools',
      name: 'Chrome DevTools',
      command: 'npx',
      args: ['-y', '@upaya/mcp-chrome-devtools'],
    ),
    McpServerConfig(
      id: 'filesystem',
      name: 'FileSystem',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-filesystem', '/tmp'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('mcp_servers');
      
      if (configJson != null) {
        final List<dynamic> decoded = jsonDecode(configJson);
        _servers = decoded
            .map((json) => McpServerConfig.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // 首次加载,使用预设配置
        _servers = List.from(_presetServers);
      }
    } catch (e) {
      _showError('加载配置失败: $e');
      _servers = List.from(_presetServers);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(_servers.map((s) => s.toJson()).toList());
      await prefs.setString('mcp_servers', configJson);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置已保存'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      _showError('保存配置失败: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 服务器配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
            tooltip: '保存配置',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildServerList(),
    );
  }

  Widget _buildServerList() {
    if (_servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.extension_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无MCP服务器配置',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addPresetServers,
              icon: const Icon(Icons.add),
              label: const Text('添加预设服务器'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _servers.length,
      itemBuilder: (context, index) {
        return _buildServerCard(_servers[index], index);
      },
    );
  }

  Widget _buildServerCard(McpServerConfig server, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${server.command} ${server.args.join(' ')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: server.enabled,
                  onChanged: (value) {
                    setState(() {
                      _servers[index].enabled = value;
                    });
                  },
                  activeColor: AppTheme.accentColor,
                ),
              ],
            ),
            if (server.enabled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '已启用',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.successColor,
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

  void _addPresetServers() {
    setState(() {
      _servers = List.from(_presetServers);
    });
    _saveConfig();
  }
}
