# KFC 应用图标制作指南

## 📱 图标规格要求

### Android 图标尺寸
- **启动图标 (Launcher Icon)**:
  - `mipmap-mdpi`: 48x48 px
  - `mipmap-hdpi`: 72x72 px
  - `mipmap-xhdpi`: 96x96 px
  - `mipmap-xxhdpi`: 144x144 px
  - `mipmap-xxxhdpi`: 192x192 px

### 设计建议
- **主色调**: 米白色 (#F5F5F0)
- **强调色**: 蓝色 (#4A90E2)
- **图标主题**: 简洁现代的KFC字母或图形
- **圆角**: Android 推荐使用自适应图标
- **背景**: 纯色或简单图案,避免渐变

## 🎨 制作图标的方法

### 方法1: 使用在线工具 (最简单)
1. **访问 [App Icon Generator](https://appicon.co/)**
   - 上传一张 1024x1024 的设计图
   - 选择 Android 平台
   - 自动生成所有尺寸

2. **访问 [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html)**
   - 上传图片或使用文字
   - 自定义颜色和样式
   - 下载生成的图标包

### 方法2: 使用设计软件
**推荐软件**:
- Figma (免费在线)
- Adobe Illustrator
- Sketch (Mac)
- Canva (简单易用)

**设计步骤**:
1. 创建 1024x1024 的画布
2. 设计KFC图标:
   ```
   建议设计:
   - 圆形背景: 米白色 #F5F5F0
   - KFC 字母: 蓝色 #4A90E2
   - 字体: 粗体无衬线
   - 留白: 周围留 15-20% 安全区
   ```
3. 导出 PNG 格式
4. 使用在线工具生成多尺寸

### 方法3: 使用 Flutter 工具自动生成

1. **安装 flutter_launcher_icons 插件**
```yaml
# 在 pubspec.yaml 添加
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#F5F5F0"
  adaptive_icon_foreground: "assets/icon/app_icon_fg.png"
```

2. **准备图标文件**
- 在项目中创建 `assets/icon/` 目录
- 放入 1024x1024 的 `app_icon.png`
- (可选) 放入前景图 `app_icon_fg.png`

3. **运行生成命令**
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## 📂 手动替换图标文件

如果你已经有设计好的图标,可以手动替换:

### Android 图标位置
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png      (48x48)
├── mipmap-hdpi/ic_launcher.png      (72x72)
├── mipmap-xhdpi/ic_launcher.png     (96x96)
├── mipmap-xxhdpi/ic_launcher.png    (144x144)
└── mipmap-xxxhdpi/ic_launcher.png   (192x192)
```

### 替换步骤
1. 准备好所有尺寸的图标
2. 重命名为 `ic_launcher.png`
3. 替换对应目录下的文件
4. 重新编译应用

## 🎯 快速制作 KFC 图标示例

### 简单设计 (纯文字)
```
背景: 米白色圆形 #F5F5F0
文字: KFC (蓝色 #4A90E2)
字体: Roboto Bold 或 SF Pro Bold
效果: 简洁专业
```

### 创意设计 (图形+文字)
```
背景: 米白色
图标: 对话气泡图形 (轮廓蓝色)
文字: KFC 小字在下方
效果: 突出聊天功能
```

## 🔧 修改应用名称

同时可以修改应用显示名称:

**Android**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:label="KFC"  <!-- 修改这里 -->
    ...>
```

**当前配置**:
- 应用名称: "KFC"
- 包名: com.kimi.kfc.kfc

## ✅ 测试检查清单

- [ ] 图标在所有尺寸下都清晰
- [ ] 图标在深色/浅色背景都好看
- [ ] 图标符合品牌色调 (米白+蓝)
- [ ] 重新编译后图标正确显示
- [ ] 在真机上测试显示效果

## 📝 推荐工作流程

1. 使用 Canva 或 Figma 设计 1024x1024 图标
2. 导出 PNG 文件
3. 上传到 https://appicon.co/ 生成所有尺寸
4. 下载图标包
5. 解压并替换 `android/app/src/main/res/mipmap-*/` 下的文件
6. 运行 `flutter clean && flutter build apk`
7. 在手机上测试

---

**推荐设计**:
- 简洁的 "KFC" 字母标识
- 米白色背景配蓝色字体
- 或者蓝色圆形背景配白色字体
- 避免过于复杂的设计

**注意事项**:
- 图标会被缩小到很小尺寸,保持简洁
- 避免使用过细的线条
- 留足够的边距(安全区)
- PNG 格式,透明背景或纯色背景
