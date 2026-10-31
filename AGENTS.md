# AGENTS.md

本仓库是 HarmonyOS Stage 模型应用，目标是手机计算器。改代码前先读本文。

## 现状

- 入口 Ability：`entry/src/main/ets/entryability/EntryAbility.ets`，加载 `pages/Index`。
- 唯一页面：`entry/src/main/ets/pages/Index.ets`，仍是 Hello World 模板。
- 备份扩展 `EntryBackupAbility` 只打日志，没有业务数据。
- 测试是 Hypium 模板，断言 `'abc'` 包含 `'b'`，不能当作计算器行为的覆盖。

计算器的按键、表达式和结果放在 `entry/src/main/ets/`。界面文案、颜色、字号放进 `entry/src/main/resources/`，不要在组件里写死用户可见字符串。

## 约定

- 保持 Stage 模型、ArkTS 和 ArkUI。设备类型保持 `phone`，除非任务明确要求扩展。
- 页面必须登记到 `entry/src/main/resources/base/profile/main_pages.json`。
- 新增依赖写在对应的 `oh-package.json5`，并更新 `oh-package-lock.json5`。
- 应用名在 `AppScope/resources/base/element/string.json` 的 `app_name`。包名在 `AppScope/app.json5`。
- 跟随现有资源引用方式，例如 `$r('app.float.page_text_font_size')`、`$string:`。
- 用户可见文案用中文。代码标识符用英文。
- 运算放在页面或独立模块。`EntryAbility` 只负责创建窗口并加载页面。

## 验证

在 DevEco Studio 中编译并运行 `entry`。改到测试时，用 Hypium 跑 `entry/src/test`；涉及 Ability 或界面时再跑 `entry/src/ohosTest`。
