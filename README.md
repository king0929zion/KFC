# KFC - Kimi Flutter Client

> 🤖 将完整的 Kimi CLI 集成到 Android 的 Flutter 应用

## 项目特色

- 🐍 **Python 集成** - 通过 Chaquopy 在 Android 上运行 Python 3.13
- ✨ **流式输出** - 实时打字机效果，流畅的 AI 对话体验
- 🎨 **现代 UI** - 精美的界面设计，丰富的动画效果
- 📦 **工具调用** - 支持 MCP 工具集成
- 💾 **本地存储** - SQLite 数据库管理会话历史

## 技术栈

- **前端**: Flutter 3.24.5
- **后端**: Python 3.13 (Chaquopy)
- **数据库**: sqflite (SQLite)
- **状态管理**: Provider
- **代码高亮**: flutter_highlight

## 快速开始

### 环境要求

- Flutter SDK 3.24.5+
- Java JDK 21+
- Android SDK
- Python 3.8+

### 本地运行

```bash
# 克隆仓库
git clone https://github.com/ClairSchidt/KFC.git
cd KFC

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 构建 APK

```bash
# 构建 Release APK
flutter build apk --release --split-per-abi

# 构建 App Bundle
flutter build appbundle --release
```

## GitHub Actions 自动构建

每次推送到 `main` 或 `master` 分支时，GitHub Actions 会自动：

1. 生成签名密钥库
2. 构建多架构 APK (arm64-v8a, armeabi-v7a, x86_64)
3. 构建 App Bundle (.aab)
4. 上传产物到 Actions 
5. 如果是 tag 推送，自动创建 Release

### 创建 Release

```bash
# 打标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 配置 Secrets（可选）

如果需要自定义签名密码，在仓库 Settings > Secrets 中添加：

- `KEYSTORE_PASSWORD` - 密钥库密码
- `KEY_PASSWORD` - 密钥密码

## 功能特性

### 已实现

- ✅ 流式输出动画
- ✅ 消息长按菜单（复制/删除/重试）
- ✅ 会话历史管理
- ✅ MCP 工具配置
- ✅ 代码高亮显示
- ✅ 权限管理
- ✅ 错误处理系统

### 计划中

- ⏳ 完整 Kimi CLI 集成
- ⏳ 工具调用可视化
- ⏳ 语音输入/输出
- ⏳ 图片上传分析
- ⏳ 多语言支持

## 项目结构

```
kfc/
├── lib/
│   ├── config/         # 配置文件
│   ├── models/         # 数据模型
│   ├── screens/        # 页面
│   ├── services/       # 业务服务
│   ├── utils/          # 工具类
│   └── widgets/        # UI组件
├── android/
│   └── app/
│       ├── src/main/python/  # Python代码
│       └── build.gradle.kts
└── .github/
    └── workflows/
        └── build-apk.yml
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 致谢

- [Flutter](https://flutter.dev/)
- [Chaquopy](https://chaquo.com/chaquopy/)
- [Kimi CLI](https://github.com/moonbitlang/kimi-cli)
