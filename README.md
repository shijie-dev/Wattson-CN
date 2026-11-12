# Wattson-CN

**Wattson 的简体中文本地化版本，支持中文和英文界面。**

基于 [TheFilipcom4607/Wattson](https://github.com/TheFilipcom4607/wattson) 2.8
（提交 `9e7e54cadacc57b34cb3da3ef13b23b904410515`）。原作者为 TheFilip；
本仓库由 shijie-dev 维护本地化和独立应用打包，属于社区衍生版本，并非官方中文发行版。
原始功能介绍见 [上游 README](README.upstream.md)。

## 功能

- 菜单栏实时功率、电池电量及充放电状态。
- 电源适配器、USB-C、Thunderbolt、线缆和外接设备信息。
- 功耗曲线、CPU 性能节流信息及低电量模式设置。
- 中文菜单、设置、通知、工具提示和动态状态文本；英语环境仍保留英文。
- 独立的应用身份，可与官方 Wattson 并存，不覆盖官方应用或迁移其配置。

传感器读取、功率计算、设备识别及 PD 解析逻辑保持上游原样。
硬件型号、制造商、序列号、协议名和单位保持原文。
原版没有提供的指标或功能不会因汉化而新增。

## 下载与运行

前往 [Releases](https://github.com/shijie-dev/Wattson-CN/releases) 查看可用的预编译版本。
如果尚无发行包，可以使用下方命令从源码构建。

要求：Apple Silicon Mac、macOS 13 或更新版本。
解压后启动 `Wattson-CN.app`，应用位于菜单栏，不显示 Dock 图标。
界面默认跟随系统语言，不需要安装额外语言包。

社区构建采用 ad-hoc 签名，未进行 Apple 公证，首次打开可能被系统拦截。
请先确认文件来源，再使用 macOS 提供的“仍要打开”方式；无需关闭系统安全功能。

## 从源码构建

安装 Apple Command Line Tools 和 Python 3，然后运行：

```sh
git clone https://github.com/shijie-dev/Wattson-CN.git
cd Wattson-CN
./build-cn.sh
```

产物为 `dist/Wattson-CN.app`。构建脚本不会安装或启动应用，也不会修改 `/Applications`。
可通过 `WATTSON_CN_OUTPUT` 环境变量指定另一个输出目录。

本地化维护和验证：

```sh
python3 Tools/localize.py
Tools/test-localization.sh
./build-cn.sh
./dist/Wattson-CN.app/Contents/MacOS/Wattson-CN --selftest
```

## 本地化与验证范围

- `Sources/Wattson/Resources/zh-Hans.lproj/Localizable.strings`：简体中文资源。
- `Sources/Wattson/Resources/en.lproj/Localizable.strings`：英文资源。
- `Tools/translations.txt` 与 `Tools/extra-translations.json`：翻译维护源。
- `LOCALIZATION-CN.md`：实现细节、权限说明和测试范围。

初版完成 386 条资源的占位符检查，中英文各 407 个文本测试、上游 298 项自测通过，
并检查了实际 SwiftUI/AppKit 渲染的主面板和四个设置页。
未覆盖所有设备、故障状态或授权交互；请勿将其理解为全部硬件兼容性保证。
原始诊断报告、CLI/JSON 字段及操作系统返回的底层错误保持英文，方便与上游排查。

## 与官方版的区别

独立版 Bundle Identifier 为 `com.filip.wattson.cn`。
偏好设置、通知授权和登录项与官方版本分离。
可选低电量模式授权规则使用独立文件名，权限范围沿用上游；默认不会安装此规则。
若用户手动更改低电量模式，两份应用都会显示同一台 Mac 的系统状态。

## 致谢与许可证

感谢 [TheFilip](https://github.com/TheFilipcom4607) 创建 Wattson。
保留上游 [MIT 许可证和版权声明](LICENSE)，本仓库新增本地化代码亦采用 MIT 许可证。
上游提及的 whatcable 和 whatport 等项目致谢保留在原始 README 中。
