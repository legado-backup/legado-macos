# 手工测试

这些脚本验证数据库初始化、RSS 数据模型、JSON 结构和基础解析逻辑。

它们依赖项目源码或 macOS Swift 环境，当前不属于 SwiftPM 自动测试 target。运行前先完成一次：

```bash
swift build
```

脚本说明：

- test_integration.swift：RSS 数据库 CRUD 集成检查。
- test_rss.swift：RSS 模型和规则基础检查。
- test_rss_engine.swift：RSS/Atom 文本解析基础检查。
- test_rss_source_json.swift：订阅源 JSON 结构检查。
- LocalBookImportPerformance.md：本地 TXT/EPUB 按章节读取、阅读页局部导航、缓存清理和备份恢复检查。
- BookSourceSearchAndImport.md：书源搜索取消、书籍信息回填和 `@put/@get` 规则回归检查。
- ReaderChapterRefresh.md：阅读器强制刷新当前章节和后续缓存章节的手工检查。

历史脚本中的绝对路径和旧日志仅用于追溯，新增测试应使用仓库相对路径。

运行 `bash Tests/Manual/run_dom_regression.sh` 验证 Android DOM 规则兼容性（11 项离线断言，不依赖 XCTest）。

`AdvancedRuleRegression.swift` 随 `run_dom_regression.sh` 运行，覆盖模板、查询语法、JS 隔离和内存网络请求/分页/取消。无需访问公网。

### 订阅网页手工验证

1. 打开 singleUrl 订阅，确认显示网页；点击站内链接，验证后退、前进与刷新。
2. 打开有 sortUrl 的订阅，点击分类链接，确认应用内弹窗展示，关闭后返回分类列表。
3. 普通文章点击“应用内查看原文”；确认已读标记及原有“提取正文”功能可用。
4. 点击 target=_blank 链接，确认在内置页面继续导航；“浏览器打开”使用当前地址。
5. 断网或访问无效域名，确认错误与重试按钮；关闭网页后不再继续加载。
6. 尝试非 HTTP/HTTPS 地址，确认不启动本地程序；无法显示的文件响应提示使用浏览器。
7. 在较小窗口验证工具栏、关闭按钮、键盘 Escape 关闭以及网页滚动。

### 界面动效手工检查

- 设置切换三种主题、重启后确认选择保留；检查主导航过渡及阅读器工具栏。
- 网页导航按钮测试悬停、按下、禁用、键盘焦点；窗口缩小及深浅色下检查文字可读性。
- 开启系统减少动态效果，确认自定义按压缩放、位移和过渡关闭。
- 加载网页时观察真实进度条及停止按钮；刷新、返回不应因界面更新重载页面。
- 断网验证错误提示进入及重试；文章收藏图标立即更新，提取正文时按钮不能重复触发。
