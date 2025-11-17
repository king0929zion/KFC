import 'package:flutter/material.dart';
import 'package:kfc/config/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设置界面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelNameController = TextEditingController();
  
  bool _isLoading = true;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _baseUrlController.text = prefs.getString('base_url') ?? '';
      _modelNameController.text = prefs.getString('model_name') ?? '';
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
      await prefs.setString('model_name', _modelNameController.text);

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
        title: const Text('设置'),
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
                _buildSection(
                  title: 'API 配置',
                  icon: Icons.api,
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _modelNameController,
                      decoration: const InputDecoration(
                        labelText: '模型名称',
                        hintText: 'moonshot-v1-8k',
                        prefixIcon: Icon(Icons.memory),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '关于',
                  icon: Icons.info_outline,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.apps),
                      title: Text('应用名称'),
                      subtitle: Text('Kimi Flutter Client (KFC)'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.code),
                      title: Text('版本'),
                      subtitle: Text('0.1.0'),
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
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
