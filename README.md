# Legado for macOS

<p align="center">
  <img src="./Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" alt="Legado for macOS 图标" width="96">
</p>

Legado for macOS 是基于 SwiftUI 的原生阅读器，目标是把 Android 版 Legado 的书源、书架和阅读能力迁移到 macOS，同时保留 Legado 的 JSON 规则格式。

## 当前能力

- 书源导入、编辑、启用/禁用和批量导出。
- Android 版书源 JSON、书架 JSON 导入。
- TXT 与 EPUB 本地导入、章节识别和按章节读取。
- 在线搜索、书源发现、换源、章节缓存和预加载。
- 多链接目录/正文分页、重定向基址、统一请求配置及每次解析操作的 JS 状态隔离。
- CSS、JSONPath 联合/切片/简单过滤、XPath 节点查询、正则和 JavaScript 规则解析。
- Android JSOUP 链式规则、索引区间/排除、连接符、AllInOne、OnlyOne 和递归 JSONPath。
- 标准 RSS/Atom、自定义 RSS 规则、分页和文章正文。
- 订阅网页内置浏览：单页订阅直接展示、分类链接和文章原文在应用内打开，支持前进、后退和刷新。
- 阅读进度、滚动位置、书签、阅读历史和替换规则。
- 灵动、轻盈、静止三种界面动效主题，支持系统减少动态效果。
- JSON 数据备份恢复、封面缓存、网络代理和自定义快捷键。

依赖 Android WebView、Java 类（例如 OkHttp）、登录 UI、音频/图片书专用渲染和 iCloud 同步的功能仍属于兼容边界。

规则兼容性可通过 `Tests/Manual/run_dom_regression.sh` 的离线回归用例检查。

## 界面预览

界面采用 macOS 原生深色布局，覆盖书架、书源、订阅、阅读和项目介绍等主要使用场景。图片按两列排列，GitHub 页面会根据屏幕宽度自动缩放。

<table>
  <tr>
    <td align="center" width="50%">
      <img src="./Resources/书架页面.png" alt="书架页面" width="100%">
      <br>
      <sub>书架：管理本地书籍、在线书籍和阅读进度</sub>
    </td>
    <td align="center" width="50%">
      <img src="./Resources/书源页面.png" alt="书源页面" width="100%">
      <br>
      <sub>书源：导入、筛选、启用和管理 Legado 书源</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="./Resources/阅读页面.png" alt="阅读页面" width="100%">
      <br>
      <sub>阅读：章节阅读、局部章节导航和阅读设置</sub>
    </td>
    <td align="center" width="50%">
      <img src="./Resources/订阅页面.png" alt="订阅页面" width="100%">
      <br>
      <sub>订阅：管理 RSS/Atom 订阅源和文章</sub>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <img src="./Resources/关于页面.png" alt="关于页面" width="52%">
      <br>
      <sub>关于：查看版本、更新日志、作者和项目地址</sub>
    </td>
  </tr>
</table>

## 快速开始

环境要求：macOS 13+、Swift 5.9+，建议使用 Xcode 15+ 或匹配的 Command Line Tools。

```bash
# 开发构建
swift build

# 运行开发版本
swift run

# 生成可双击运行的 macOS App
./build_app.sh
open Legado.app

# 生成 GitHub Release 附件（默认只打包，不上传）
./release.sh
```

build_app.sh 会自动定位当前架构的 SwiftPM Release 二进制，组装应用包，生成图标，执行 ad-hoc 签名并校验包结构。发布包由 release.sh 生成在 dist/ 中；该目录已被 Git 忽略，可用作 GitHub Release 附件。

## 2.0.6 使用说明

- 单网页订阅直接展示网页；分类链接和文章详情中的“应用内查看原文”在应用内打开。
- 网页工具栏提供前进、后退、刷新、停止加载和外部浏览器入口。
- “设置 → 通用 → 界面动效”可选择灵动、轻盈、静止，默认灵动；系统减少动态效果优先。
- 内置网页使用系统网络配置，不继承应用自定义代理或书源请求头；网页登录状态仅保留在当前会话。下载请使用外部浏览器。

## 仓库结构

```text
.
├── README.md
├── Package.swift
├── Package.resolved
├── build_app.sh
├── release.sh
├── Sources/       # SwiftUI 页面、业务状态、模型、规则、数据库与网络
├── Resources/     # 应用信息、图标与界面截图
├── Scripts/       # 图标生成等辅助脚本
└── Tests/Manual/  # 离线回归脚本与手工验证步骤
```

## 常用入口

| 需求 | 入口 |
| --- | --- |
| 运行项目 | `swift run` |
| 构建 App | `./build_app.sh` |
| 生成发布附件 | `./release.sh` |
| 规则回归检查 | `bash Tests/Manual/run_dom_regression.sh` |
| 手工检查说明 | [Tests/Manual/README.md](Tests/Manual/README.md) |

## 数据位置

应用运行数据位于：

```text
~/Library/Application Support/Legado/
├── legado.db             # SQLite 数据库
├── Books/                # 本地书籍源文件和章节缓存
├── covers/               # 封面缓存
├── reader_config.json    # 阅读器配置
└── main_app_config.json  # 应用配置
```

应用内「设置 → 通用 → 备份数据」会导出书架、书源、章节缓存、RSS、书签和阅读历史。恢复备份前请确认目标文件可信。

## 开发约定

新增功能应放入对应的 Sources/ 模块，并同步更新 README 或手工验证说明。数据库结构变更必须通过 DatabaseManager 的迁移逻辑完成；书源和 RSS 规则应优先复用 LegadoRuleParser。

提交前至少运行：

```bash
bash -n build_app.sh
swift build
swift build -c release
git diff --check
```

## 许可证

本项目遵循 GPL-3.0。原始项目：https://github.com/gedoor/legado。
