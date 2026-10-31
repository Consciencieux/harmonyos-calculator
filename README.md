# Calculator

HarmonyOS 手机计算器。当前仓库是 DevEco Studio 的 Stage 模型工程，界面仍是模板页，还没有运算逻辑。

| 项 | 值 |
| --- | --- |
| 包名 | `com.example.calculator` |
| 版本 | `1.0.0` |
| 目标 SDK | `26.0.0` |
| 兼容 SDK | `6.1.1(24)` |
| 设备 | 手机 |
| 语言 | ArkTS / ArkUI |

## 运行

用 DevEco Studio 打开本目录，等待 hvigor 同步依赖后，在手机或模拟器上运行 `entry` 模块。

启动后进入 `pages/Index`。页面居中显示 `Hello World`，点击后变为 `Welcome`。

## 目录

```
AppScope/                 应用名、图标、版本
entry/src/main/ets/       Ability、页面
entry/src/main/resources/ 字符串、颜色、字号、路由
entry/src/test/           本地单元测试（Hypium）
entry/src/ohosTest/       仪器测试（Hypium）
```

页面路由在 `entry/src/main/resources/base/profile/main_pages.json`，目前只有 `pages/Index`。
