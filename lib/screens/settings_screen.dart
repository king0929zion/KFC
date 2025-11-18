import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kfc/models/ai_model.dart';
import 'package:kfc/models/mcp_server.dart';

/// 设置界面 - 主导航页
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildNavigationTile(
            context,
            icon: Icons.api,
            title: 'API 配置',
            subtitle: '配置 API Key 和模型',
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const ApiConfigScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          _buildNavigationTile(
            context,
            icon: Icons.extension,
            title: 'MCP 配置',
            subtitle: '管理 MCP 服务器',
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const McpConfigScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          _buildNavigationTile(
            context,
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '应用信息和版本',
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AboutScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// API 配置界面
class ApiConfigScreen extends StatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _manualModelController = TextEditingController();
  
  bool _isLoading = true;
  bool _obscureApiKey = true;
  bool _isFetchingModels = false;
  List<AiModel> _availableModels = [];
  List<AiModel> _selectedModels = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _manualModelController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _baseUrlController.text = prefs.getString('base_url') ?? '';
      
      // 加载已选择的模型
      final modelsJson = prefs.getString('selected_models');
      if (modelsJson != null) {
        final List<dynamic> modelsList = json.decode(modelsJson);
        _selectedModels = modelsList
            .map((m) => AiModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _showError('加载设置失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_key', _apiKeyController.text);
      await prefs.setString('base_url', _baseUrlController.text);
      
      // 保存已选择的模型
      final modelsJson = json.encode(
        _selectedModels.map((m) => m.toJson()).toList(),
      );
      await prefs.setString('selected_models', modelsJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      _showError('保存失败: $e');
    }
  }

  /// 从 OpenAI 协议的 API 获取可用模型列表
  Future<void> _fetchAvailableModels() async {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (baseUrl.isEmpty || apiKey.isEmpty) {
      _showError('请先配置 Base URL 和 API Key');
      return;
    }

    setState(() => _isFetchingModels = true);

    try {
      final url = baseUrl.endsWith('/')
          ? '${baseUrl}models'
          : '$baseUrl/models';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> models = data['data'] ?? [];

        setState(() {
          _availableModels = models
              .map((m) => AiModel(
                    id: m['id'],
                    name: m['id'],
                    description: m['owned_by'] ?? '',
                  ))
              .toList();
        });

        if (_availableModels.isEmpty) {
          _showError('未找到可用模型');
        } else {
          _showModelSelectionDialog();
        }
      } else {
        final snippet = response.body.length > 120
            ? response.body.substring(0, 120) + '...'
            : response.body;
        _showError('获取模型失败: ${response.statusCode}，请确认 Base URL 以 /v1 结尾。\n响应: $snippet');
      }
    } catch (e) {
      _showError('网络请求失败: $e');
    } finally {
      setState(() => _isFetchingModels = false);
    }
  }

  /// 显示模型选择对话框
  void _showModelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('选择模型'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableModels.length,
              itemBuilder: (context, index) {
                final model = _availableModels[index];
                final isSelected = _selectedModels
                    .any((m) => m.id == model.id);

                return CheckboxListTile(
                  title: Text(model.name),
                  subtitle: model.description != null
                      ? Text(model.description!)
                      : null,
                  value: isSelected,
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        _selectedModels.add(model);
                      } else {
                        _selectedModels.removeWhere(
                          (m) => m.id == model.id,
                        );
                      }
                    });
                    setState(() {}); // 更新主界面
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveSettings();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('API 配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '保存',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://api.moonshot.cn/v1',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: '输入您的 API Key',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureApiKey = !_obscureApiKey;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureApiKey,
                ),
                const SizedBox(height: 24),
                
                // 获取模型按钮
                ElevatedButton.icon(
                  onPressed: _isFetchingModels ? null : _fetchAvailableModels,
                  icon: _isFetchingModels
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cloud_download),
                  label: Text(_isFetchingModels ? '获取中...' : '获取可用模型'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _manualModelController,
                  decoration: const InputDecoration(
                    labelText: '手动添加模型',
                    hintText: '输入模型名，例如 moonshot-v1-8k',
                    prefixIcon: Icon(Icons.model_training),
                  ),
                  onSubmitted: (value) {
                    final name = value.trim();
                    if (name.isEmpty) {
                      _showError('请输入模型名');
                      return;
                    }
                    setState(() {
                      _selectedModels.add(AiModel(
                        id: name,
                        name: name,
                        description: '手动添加',
                      ));
                    });
                    _manualModelController.clear();
                    _saveSettings();
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final name = _manualModelController.text.trim();
                    if (name.isEmpty) {
                      _showError('请输入模型名');
                      return;
                    }
                    setState(() {
                      _selectedModels.add(AiModel(
                        id: name,
                        name: name,
                        description: '手动添加',
                      ));
                    });
                    _manualModelController.clear();
                    _saveSettings();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('添加模型'),
                ),
                
                // 已选择的模型列表
                if (_selectedModels.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '已选择的模型',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedModels.map(
                    (model) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                        title: Text(model.name),
                        subtitle: model.description != null
                            ? Text(model.description!)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AppTheme.errorText,
                          onPressed: () {
                            setState(() {
                              _selectedModels.removeWhere(
                                (m) => m.id == model.id,
                              );
                            });
                            _saveSettings();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// MCP 配置界面
class McpConfigScreen extends StatefulWidget {
  const McpConfigScreen({super.key});

  @override
  State<McpConfigScreen> createState() => _McpConfigScreenState();
}

class _McpConfigScreenState extends State<McpConfigScreen> {
  List<McpServer> _mcpServers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = prefs.getString('mcp_servers');
      
      if (serversJson != null) {
        final List<dynamic> serversList = json.decode(serversJson);
        _mcpServers = serversList
            .map((s) => McpServer.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _showError('加载服务器列表失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveServers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = json.encode(
        _mcpServers.map((s) => s.toJson()).toList(),
      );
      await prefs.setString('mcp_servers', serversJson);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      _showError('保存失败: $e');
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

  void _showAddServerDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    McpProtocol selectedProtocol = McpProtocol.sse;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加 MCP 服务器'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '服务器名称',
                    hintText: '例: My MCP Server',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: '服务器 URL',
                    hintText: 'https://example.com/mcp',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<McpProtocol>(
                  value: selectedProtocol,
                  decoration: const InputDecoration(
                    labelText: '协议类型',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: McpProtocol.sse,
                      child: Text('SSE (Server-Sent Events)'),
                    ),
                    DropdownMenuItem(
                      value: McpProtocol.https,
                      child: Text('HTTPS'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedProtocol = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final url = urlController.text.trim();

                if (name.isEmpty || url.isEmpty) {
                  _showError('请填写完整信息');
                  return;
                }

                final server = McpServer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  url: url,
                  protocol: selectedProtocol,
                );

                setState(() {
                  _mcpServers.add(server);
                });

                _saveServers();
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteServer(McpServer server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除服务器 "${server.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _mcpServers.removeWhere((s) => s.id == server.id);
              });
              _saveServers();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorText,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServerDialog,
            tooltip: '添加服务器',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mcpServers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.extension_off,
                        size: 64,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无 MCP 服务器',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showAddServerDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('添加第一个服务器'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mcpServers.length,
                  itemBuilder: (context, index) {
                    final server = _mcpServers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: server.enabled
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.extension,
                            color: server.enabled
                                ? AppTheme.successColor
                                : AppTheme.textSecondary,
                          ),
                        ),
                        title: Text(server.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(server.url),
                            const SizedBox(height: 4),
                            Text(
                              server.protocol == McpProtocol.sse
                                  ? 'SSE'
                                  : 'HTTPS',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.accentColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: server.enabled,
                              onChanged: (value) {
                                setState(() {
                                  final index = _mcpServers.indexWhere(
                                    (s) => s.id == server.id,
                                  );
                                  if (index != -1) {
                                    _mcpServers[index] = server.copyWith(
                                      enabled: value,
                                    );
                                  }
                                });
                                _saveServers();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppTheme.errorText,
                              onPressed: () => _deleteServer(server),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

/// 关于界面
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.apps),
            title: Text('应用名称'),
            subtitle: Text('KFC'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('版本'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('开源协议'),
            subtitle: const Text('Apache License 2.0'),
            onTap: () {
              // TODO: 显示开源协议
            },
          ),
        ],
      ),
    );
  }
}
