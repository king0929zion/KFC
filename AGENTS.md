# KFC 项目规范文档

> KFC - 完整集成 kimi-cli 的 Android AI 助手应用

## 📋 项目概述

KFC 是一个基于 Flutter 开发的 Android 应用，**完整集成 kimi-cli 的所有功能**，将命令行 AI 助手能力带到移动端。

### 核心原则

1. **完整保留 kimi-cli 功能** - 不得简化或修改核心业务流程，仅新增 UI 层
2. **本地源码集成** - kimi-cli 源码内置在项目中，而非外部依赖
3. **Python 3.13 环境** - 使用 Chaquopy 运行完整的 Python 环境

---

## 🎨 UI 设计规范

### 配色方案 - 米白主题

```dart
primaryBackground: #F5F5F0    // 主背景 米白色
cardBackground: #FFFFFF       // 卡片背景 纯白
lightBackground: #FEFEE8      // 浅米色背景
codeBackground: #F8F8F8       // 代码背景

textPrimary: #2C2C2C         // 文字主色 深灰
textSecondary: #8B8B8B       // 文字副色 中灰
textTertiary: #B8B8B8        // 文字三级色 浅灰

accentColor: #4A90E2         // 强调色 蓝色
borderColor: #E5E5E0         // 边框色
dividerColor: #F0F0EB        // 分割线色

errorText: #E53935           // 错误文字
successColor: #4CAF50        // 成功色
```

### UI 元素规范

#### 1. 消息显示
- **用户消息**: 右对齐，浅蓝背景气泡，深灰文字
- **AI 消息**: 左对齐，纯文本无气泡，**不显示头像**
- **支持 Markdown 渲染** - 使用 flutter_markdown
- **禁止模拟打字效果** - 直接显示完整内容

#### 2. 空状态
- **主页面无消息时**: 直接显示空白对话区域
- **禁止显示**: 欢迎语、示例提示、引导芯片

#### 3. 输入框
- 占位符文本: "哈啦..."
- 无焦点高亮色
- 米白色背景，圆角 24px

#### 4. 顶部状态栏
- **实色背景** (#F5F5F0)
- 禁止半透明或渐变效果

#### 5. 页面动画
- 设置页面进入: 右滑动画，300ms，Curves.easeOutCubic
- PageRouteBuilder + SlideTransition

---

## 🏗️ 技术架构

### 技术栈

```yaml
Flutter: SDK ^3.5.0
Dart: ^3.5.0
Android:
  - minSdk: 24
  - targetSdk: 35
  - compileSdk: 35
  - NDK: 27.0.12077973
  - Kotlin: 1.9.0
  - Gradle: 8.14
  - Java: 21

Python:
  - Version: 3.13
  - Framework: Chaquopy 16.0.0
```

### 核心依赖

```yaml
# Flutter 依赖
provider: ^6.1.2           # 状态管理
sqflite: ^2.3.3+1          # 本地数据库
path_provider: ^2.1.3       # 路径访问
shared_preferences: ^2.2.3  # 配置存储
flutter_markdown: ^0.7.3+1  # Markdown 渲染
http: ^1.2.1               # HTTP 客户端

# Python 依赖 (Chaquopy)
kimi-cli 完整依赖:
  - agent-client-protocol==0.6.3
  - aiofiles==25.1.0
  - aiohttp==3.13.2
  - typer==0.20.0
  - kosong==0.25.0
  - loguru==0.7.3
  - patch-ng==1.19.0
  - prompt-toolkit==3.0.52
  - pillow==12.0.0
  - pyyaml==6.0.3
  - rich==14.2.0
  - ripgrepy==2.2.0
  - streamingjson==0.0.5
  - trafilatura==2.0.0
  - tenacity==9.1.2
  - fastmcp==2.12.5
  - pydantic==2.12.4
  - httpx[socks]==0.28.1
```

---

## 📁 项目结构

```
kfc/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── config/
│   │   └── theme.dart              # 主题配置 (米白主题)
│   ├── models/
│   │   ├── message.dart            # 消息模型
│   │   ├── stream_message.dart     # 流式消息模型
│   │   ├── ai_model.dart           # AI 模型配置
│   │   └── mcp_server.dart         # MCP 服务器配置
│   ├── screens/
│   │   ├── welcome_screen.dart     # 欢迎页
│   │   ├── chat_screen.dart        # 主聊天页
│   │   ├── history_screen.dart     # 历史记录页
│   │   └── settings_screen.dart    # 设置页 (三子页面)
│   ├── widgets/
│   │   ├── message_bubble.dart     # 消息气泡 (支持 Markdown)
│   │   └── stream_message_bubble.dart # 流式消息气泡
│   └── services/
│       └── python_bridge_service.dart # Python 桥接服务
│
├── android/
│   └── app/
│       ├── build.gradle.kts        # Android 构建配置
│       └── src/main/
│           ├── kotlin/             # Kotlin 代码
│           │   └── MainActivity.kt # 主活动 (Python 桥接)
│           └── python/             # Python 源码
│               ├── kimi_bridge.py  # Python 桥接实现
│               └── kimi_cli/       # kimi-cli 完整源码 (98 文件)
│
└── pubspec.yaml                    # Flutter 依赖配置
```

---

## 🔧 功能模块

### 1. 设置界面

#### 主导航页 (SettingsScreen)
- API 配置
- MCP 配置
- 关于

#### API 配置子页面 (ApiConfigScreen)
**功能要求**:
- Base URL 配置 (支持 OpenAI 协议)
- API Key 配置 (带隐藏/显示切换)
- **自动获取模型列表**: 
  - 通过 `/models` 接口获取
  - 用户可勾选多个模型
  - 显示已选择模型列表
  - 支持删除已选模型

**API 调用示例**:
```dart
final response = await http.get(
  Uri.parse('$baseUrl/models'),
  headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  },
);
```

#### MCP 配置子页面 (McpConfigScreen)
**功能要求**:
- 支持添加远程 MCP 服务器
- 协议类型: SSE (Server-Sent Events) 和 HTTPS
- 服务器管理: 启用/禁用、删除
- 配置项:
  - 服务器名称
  - 服务器 URL
  - 协议类型
  - 可选 Headers

**数据模型**:
```dart
class McpServer {
  final String id;
  final String name;
  final String url;
  final McpProtocol protocol; // sse / https
  final Map<String, String>? headers;
  final bool enabled;
}
```

### 2. 聊天界面

**核心功能**:
- 发送消息到 kimi-cli
- 实时显示 AI 响应
- Markdown 格式渲染
- 历史记录管理

**禁止功能**:
- ❌ 示例提示芯片
- ❌ 欢迎语
- ❌ AI 头像
- ❌ 模拟打字动画

### 3. 历史记录

**功能要求**:
- 直接展示所有历史会话
- 支持滚动查看
- 点击进入历史对话
- 无分页加载

---

## 🐍 Python 集成规范

### kimi-cli 集成方式

**关键原则**: 完整保留 kimi-cli 的所有功能和架构

#### 源码位置
```
android/app/src/main/python/kimi_cli/
├── app.py              # KimiCLI 主应用
├── session.py          # Session 管理
├── soul/               # Agent 执行引擎
│   ├── kimisoul.py    # KimiSoul 核心
│   ├── agent.py       # Agent 配置
│   ├── context.py     # Context 管理
│   └── runtime.py     # Runtime 环境
├── tools/              # 完整工具集
│   ├── bash/          # Bash 工具
│   ├── file/          # 文件操作工具
│   ├── web/           # Web 工具
│   ├── task/          # Task 工具
│   ├── dmail/         # DMail 时间旅行
│   ├── todo/          # TODO 管理
│   └── mcp.py         # MCP 集成
├── ui/                 # UI 层 (不使用)
├── utils/              # 工具函数
└── wire/               # 消息协议
```

### Python 桥接实现

**文件**: `android/app/src/main/python/kimi_bridge.py`

**核心类**: `KimiBridge`

```python
class KimiBridge:
    """完整的 Kimi CLI 桥接"""
    
    async def initialize(
        work_dir: str,
        api_key: str,
        base_url: str,
        model_name: str
    ) -> Dict[str, Any]:
        """
        初始化 Kimi CLI
        - 创建 Session
        - 创建 KimiCLI 实例
        - 加载 Agent 配置
        - 初始化 Runtime
        """
    
    async def send_message(message: str) -> Dict[str, Any]:
        """
        发送消息 - 触发完整 Agent Loop:
        1. LLM 推理
        2. Tool Calling
        3. Approval 请求
        4. Context 更新
        """
    
    def get_context_history() -> List[Dict[str, Any]]:
        """获取完整 Context 历史"""
    
    async def compact_context() -> Dict[str, Any]:
        """Context 压缩"""
    
    def get_status() -> Dict[str, Any]:
        """获取当前状态"""
    
    async def add_mcp_server(
        name: str,
        url: str,
        protocol: str,
        headers: Dict[str, str]
    ) -> Dict[str, Any]:
        """添加 MCP 服务器"""
```

### Kotlin 桥接层

**文件**: `android/app/src/main/kotlin/com/kimi/kfc/kfc/MainActivity.kt`

```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "kfc.python.bridge"
    
    // 方法:
    // - initialize
    // - sendMessage
    // - executeTool
    // - getContextHistory
    // - compactContext
    // - getStatus
}
```

### Dart 服务层

**文件**: `lib/services/python_bridge_service.dart`

```dart
class PythonBridgeService {
    static const MethodChannel _channel = 
        MethodChannel('kfc.python.bridge');
    
    // 异步方法:
    // - initialize()
    // - sendMessageStream()  // 流式输出
    // - executeTool()
    // - getContextHistory()
    // - compactContext()
    // - getStatus()
}
```

---

## 🔐 环境配置

### Android 配置

```gradle
android {
    namespace = "com.kimi.kfc.kfc"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    
    defaultConfig {
        applicationId = "com.kimi.kfc.kfc"
        minSdk = 24
        targetSdk = 35
        
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }
}

chaquopy {
    defaultConfig {
        version = "3.13"  // 必须 Python 3.13
        buildPython("python3")
        pip {
            // 安装 kimi-cli 的所有依赖
            install("agent-client-protocol==0.6.3")
            // ... 其他依赖
        }
    }
}
```

### 签名配置

**文件**: `android/key.properties`

```properties
storePassword=***
keyPassword=***
keyAlias=***
storeFile=***
```

---

## 📝 应用信息

### 应用名称

**正式名称**: KFC

**禁止使用**: 
- ❌ "Kimi Flutter Client"
- ❌ "KFC - Kimi Flutter Client"
- ❌ 任何包含全称的表述

**使用场景**:
- 应用标题: "KFC"
- 关于页面: "KFC"
- 欢迎页面: "KFC"
- 所有 UI 文本: 统一使用 "KFC"

### 应用描述

```
KFC - AI coding assistant on Android
```

---

## 🚀 开发规范

### 代码风格

#### Flutter/Dart
- 遵循 Dart 官方代码规范
- 使用 `flutter_lints`
- 文件命名: snake_case
- 类命名: PascalCase

#### Python
- 遵循 PEP 8
- 类型注解: 使用 Python 3.13 类型提示
- 异步优先: 使用 async/await

#### Kotlin
- 遵循 Kotlin 官方规范
- DSL 语法: 必须使用函数调用语法 `buildPython("python3")`

### Git 提交规范

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
perf: 性能优化
test: 测试相关
chore: 构建/工具链相关
```

### 内存管理

**Python 异步处理**:
- 所有 Python 调用必须异步处理
- 避免阻塞 UI 线程
- 提供降级模拟模式保证稳定性

**Context 管理**:
- 定期检查 Context 使用率
- 超过阈值时触发 compact_context()
- 支持手动压缩

---

## 🧪 测试要求

### 单元测试
- Python 桥接功能测试
- 数据模型序列化测试
- 工具方法测试

### 集成测试
- Flutter ↔ Kotlin ↔ Python 通信测试
- kimi-cli 功能完整性测试
- MCP 服务器连接测试

### UI 测试
- 主要用户流程测试
- 各种屏幕尺寸适配测试

---

## 📦 构建与发布

### 本地调试
```bash
flutter run -d <device-id>
```

### 发布构建
**仅通过 GitHub Actions 自动构建**:
- 推送到 main/master 分支
- 打 v* 标签
- 自动签名并生成 APK

**禁止本地构建 Release**:
```bash
# ❌ 禁止执行
flutter build apk --release
```

---

## 🔍 调试

### 日志
- Python: 日志写入 `/data/data/com.kimi.kfc.kfc/files/kfc.log`
- Flutter: 使用 `debugPrint()`
- Kotlin: 使用 `Log.d()`

### 常见问题

**1. Chaquopy 包安装失败**
- 检查 Python 版本是否为 3.13
- 确认包版本号正确
- 清理构建缓存重试

**2. kimi-cli 导入错误**
- 确认源码完整复制 (98 个文件)
- 检查 `__init__.py` 文件存在
- 验证 Python 路径配置

**3. 流式输出不工作**
- 检查 Python 异步事件循环
- 确认 Kotlin 端正确处理回调
- 验证 Dart Stream 订阅

---

## 📚 参考资源

- [kimi-cli 官方仓库](https://github.com/MoonshotAI/kimi-cli)
- [Flutter 官方文档](https://flutter.dev/docs)
- [Chaquopy 文档](https://chaquo.com/chaquopy/)
- [Material Design 3](https://m3.material.io/)

---

## 📄 License

Apache License 2.0

---

**文档版本**: 1.0  
**最后更新**: 2025-01-17  
**维护者**: KFC Development Team
