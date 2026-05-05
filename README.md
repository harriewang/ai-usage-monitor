# AI 用量监控

macOS 菜单栏插件，监控 MiniMax、智谱AI、小米 MiMo 三家 AI 平台的余额和用量。

## 功能

- 菜单栏同时显示三个平台的用量
- 进度条显示用量百分比（渐变动画）
- 一键刷新所有平台
- API Key / Cookie 本地文件存储（无 Keychain 弹窗）
- 定时自动刷新（默认 60 秒）
- 设置窗口管理各平台凭证

## 技术栈

- Swift / AppKit（纯代码，无 XIB）
- macOS 14+ (Sonoma)
- xcodegen 生成 Xcode 项目

## 构建

```bash
cd AIUsageMonitor && xcodegen generate && xcodebuild -project AIUsageMonitor.xcodeproj -scheme AIUsageMonitor -configuration Debug build
```

## 运行

用 Xcode 打开 `AIUsageMonitor.xcodeproj`，Cmd+R 运行。菜单栏出现 AI 图标。

## API 接口

| 平台 | 接口 | 认证方式 |
|------|------|----------|
| MiniMax | `GET /v1/api/openplatform/coding_plan/remains` | API Key |
| 智谱AI | `POST /api/paas/v4/chat/completions` | API Key |
| MiMo | `GET /api/v1/tokenPlan/usage` | Cookie（网页认证） |

## 项目结构

```
AIUsageMonitor/
├── App/            -- AppDelegate, main
├── Models/         -- APIProvider, UsageData, AppSettings
├── Views/          -- MenuBuilder, PlatformCardView, GradientProgressBar
├── Services/       -- APIService, KeychainService, UsageMonitor
├── Controllers/    -- SettingsWindowController
└── Extensions/     -- NSColor+Theme, AppIcon
```

## License

Apache 2.0