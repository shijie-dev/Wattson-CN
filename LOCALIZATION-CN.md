# Wattson 简体中文独立版

上游：https://github.com/TheFilipcom4607/wattson
基准提交：9e7e54cadacc57b34cb3da3ef13b23b904410515（2.8）
源码：/path/to/Wattson-CN
应用：dist/Wattson-CN.app（可通过 WATTSON_CN_OUTPUT 指定输出目录）

## 构建与语言

本机使用 Apple Silicon、Swift 6.3.3 / Command Line Tools。无需完整 Xcode。
原版在修改前 `swift build -c release` 成功（45.09 秒）。

```sh
cd /path/to/Wattson-CN
python3 Tools/localize.py
Tools/test-localization.sh
./build-cn.sh
```

直接双击输出的 Wattson-CN.app 即可启动，无需放入 /Applications。
默认跟随系统／应用语言：简体中文用中文，英语用英语。
临时测试另一种语言而不修改偏好设置：

```sh
"dist/Wattson-CN.app/Contents/MacOS/Wattson-CN" -AppleLanguages '(en)'
```

## 本地化结构

`Sources/Wattson/Resources/en.lproj/Localizable.strings` 和
`Sources/Wattson/Resources/zh-Hans.lproj/Localizable.strings` 各有 386 条。
Package.swift 声明 defaultLocalization 和原生资源处理；打包脚本将资源 bundle 放进应用。
`Localization.swift` 使用 Foundation Bundle 的原生 localizedString 查表。
对于上游已经组装好、带数值的显示字符串，按资源中的完整格式模板匹配并保留参数原文。
只有显示层调用本地化：传感器、协议、算法、JSON 输出和标识比较均不使用翻译后的数据。
制造商、型号、序列号、宗卷名保持原样；动态参数不进行任意词语替换。

翻译维护源是 `Tools/translations.txt` 和 `Tools/extra-translations.json`。
修改后运行 Tools/localize.py 生成 .strings、映射及测试样本。

## 独立身份与权限

Bundle Identifier 为 `com.filip.wattson.cn`，可执行文件名为 Wattson-CN；原图标保留。
偏好设置和通知身份与官方版分离，不自动迁移配置或通知授权。
登录项使用上游 SMAppService.mainApp，将跟随新的应用身份；未启用或注册登录项。
没有发现单独的常驻辅助程序或钥匙串访问。
可选低电量模式授权规则从 /etc/sudoers.d/wattson 改为 /etc/sudoers.d/wattson-cn，
临时文件名也隔离；授权命令和权限范围未改。未安装规则、未调用 sudo、未改变电源设置。
两份应用读取的是同一台机器；若以后手动更改低电量模式，系统状态会同时反映到两份应用中。
本地产物采用 ad-hoc 签名，未公证，不具备官方 Developer ID 的分发信任身份。
未来更换为正式签名时，应重新检查系统授权、通知和登录项，不保证自动继承。

## 验证

- 原版与中文源码 release 构建均成功；最终日志 verification/build.log 无编译警告。
- 每种语言 407 个文本用例通过：覆盖全部资源、动态数值、组合字符串、硬件名和查询词保留。
- 占位符数量检查和两份 .strings 的 plutil 检查通过。
- 19 个传感器、模型、协议、算法及自测源文件与上游逐字节一致。
- 上游 --selftest：298/298 通过，日志 verification/upstream-selftest.log。
- AppKit 实际渲染中文／英文面板和四个设置页；位于 verification/zh-Hans、verification/en。
  人工检查了中文主面板和全部设置页，当前状态下没有明显溢出或截断。
- 独立 App 在隔离测试主目录下正常运行 4 秒，无错误输出；测试后仅结束该测试进程。
- arm64 Mach-O、资源、Info.plist 和 codesign --verify --deep --strict 检查通过。
- 未覆盖官方应用、未修改其偏好设置、未修改系统安全设置。

渲染使用 `--localization-preview <目录>`，不调用 model.start，不请求权限、不注册登录项、
不修改供电状态。截图是实际 SwiftUI/AppKit 视图的离屏渲染，不代表交互流程已全部测试。
未实际切换低电量模式、授权通知、注册登录项、推出磁盘或测试全部线缆与故障状态。

## 保留英文的内容与范围

硬件型号、制造商、设备原始识别字符串、协议名称、单位按要求保留。
原始硬件诊断报告、CLI / JSON 的字段、底层操作系统返回的错误说明保留上游原文，
便于和上游定位问题；界面的说明、保存对话框及错误提示前缀已本地化。
未知的硬件／系统状态按原值回退，不猜测翻译。
原版界面没有展示的指标（例如独立 GPU 功耗、完整容量／循环数）没有新增界面，
相应 CLI / 原始报告仍维持原版，避免将汉化扩展成新功能开发。

## 后续更新

保留本仓库中的本地化提交，并将官方仓库作为 upstream 同步：

```sh
git remote add upstream https://github.com/TheFilipcom4607/wattson.git
git fetch upstream
```

审查上游版本变化后，在工作分支合并相应版本，逐项解决界面冲突，补齐新增文案，
再运行资源生成、文本测试、上游自测和 build-cn.sh。
不要直接覆盖工作目录或盲目重放一次性的源码转换脚本。
Tools/upstream-source-hashes.json 保存已审查的上游 19 个核心源文件校验值；
上游升级导致校验变化时，应先核对改动，再更新该清单。
