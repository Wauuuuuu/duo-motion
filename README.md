# Duo Motion

**让 MacBook 的开合角度，驱动桌面的流动。**

[English](README.en.md) · [MIT License](LICENSE)

Duo Motion 是一个原生 macOS 菜单栏工具。它读取兼容 MacBook 的真实铰链角度，让内置屏幕上的桌面随开合产生透视压缩、磨砂模糊和渐暗效果。展开屏幕后，画面平滑恢复。

使用 Swift、AppKit、Metal、Metal Performance Shaders、ScreenCaptureKit 和少量 C 实现，无第三方运行时依赖。本项目是独立的折叠动画实验，与 Apple 无隶属关系，不包含 Apple 的动画素材或原版着色器。

## 功能

- 菜单栏实时显示铰链角度，所有设置都在菜单中。
- 调整触发角度、磨砂程度、暗场强度和透视强度。
- 通过真实桌面画面产生可逆动画，没有演示模式或独立设置页。
- 透明首帧、渐进合成、呈现完成后暂停，以及短暂读数丢失容错。
- 检测屏幕访问权限，分别报告授权拒绝、捕获失败和超时。
- **Control + Option + Command + D** 可立即停止动画。

## 环境要求

- Apple Silicon MacBook，macOS 14 或更新版本。
- 可通过本项目的 IOHID 协议读取的铰链传感器；并非所有 MacBook 都兼容。
- Xcode Command Line Tools，以及可用的 Metal GPU。
- 使用桌面动画时，需要授予本 App「录屏与系统录音」权限。

传感器报告格式并非 Apple 承诺稳定的公开测量 API。当前读数以 1° 为步长，这不代表测量精度达到 1°。项目未完成全机型兼容性验证，也未提供经过公证的安装包。

## 构建与运行

在项目目录中运行：

```sh
zsh build.sh
open "build/Duo Motion.app"
```

首次构建默认采用本地临时签名。点击菜单栏中的笔记本角度图标，开启 **启用桌面动画**，按系统提示完成录屏授权。默认从低于 100° 开始出现效果。

所有控件均在菜单中，包括 **重新检测屏幕权限**、系统权限设置入口、**在访达中显示当前 App** 和退出操作。程序启动时动画关闭，不会安装登录启动项。

### 更新与签名

macOS 的授权与应用签名身份有关。临时签名构建的身份可能随编译变化，导致系统开关已经开启但新版仍被拒绝。

为避免意外覆盖已授权版本，构建脚本默认阻止重复的临时签名构建。开发时建议使用同一份已安装的 Apple Development 或 Developer ID Application 证书：

```sh
DUO_SIGNING_IDENTITY="证书名称或指纹" zsh build.sh
```

如果明确需要更新本地临时签名版本：

```sh
DUO_ALLOW_ADHOC_UPDATE=1 zsh build.sh
```

随后可能需要为最终版本重新授权。切换签名证书本身也可能需要重新授权。

### 系统开关已开启，仍无法访问

1. 在菜单中选择 **重新检测屏幕权限**。
2. 退出 App 后重新打开，再次检测。
3. 若系统仍拒绝当前版本，在「系统设置 → 隐私与安全 → 录屏与系统录音」中移除旧 Duo Motion 条目。
4. 使用 **在访达中显示当前 App** 确认路径，把当前的 `.app` 重新添加并开启授权，然后按系统要求重启 App。

「可访问显示器」表示内容枚举成功；「已验证画面输入」表示实际收到完整桌面帧。程序不会自动重置 TCC，也不会直接修改系统权限数据库。

## 检查

构建后运行：

```sh
"build/Duo Motion.app/Contents/MacOS/Duo Motion" --self-test
"build/Duo Motion.app/Contents/MacOS/Duo Motion" --renderer-test
"build/Duo Motion.app/Contents/MacOS/Duo Motion" --probe
```

- `--self-test`：角度映射、权限状态、计时恢复、反向开合及呈现回调时序。
- `--renderer-test`：使用合成像素进行离屏 GPU 检查，不读取桌面、不显示覆盖窗口。
- `--probe`：读取一次真实铰链角度；需要兼容的硬件。

这些检查不能替代对真实开合、系统合成及不同机型的手动验证。

## 隐私与工作方式

桌面画面只在本机内存和 GPU 中处理，不录音、不保存、不上传；App 不包含网络请求或遥测代码。

ScreenCaptureKit 排除本 App，避免将覆盖层再次捕获。画面使用 SDR，捕获宽度上限为 1920；只有内置显示器参与动画。开启动画时先验证捕获，之后在接近触发角度时预热，远离效果区间后停止捕获。

动画是位于桌面上方、允许鼠标穿透的覆盖层，不修改其他 App 的窗口。受保护内容可能无法捕获；强透视效果下，画面与实际点击位置可能不一致，展开屏幕即可恢复。正常合盖休眠不被阻止，请勿将铰链推过正常活动范围。

## 项目结构

| 文件 | 职责 |
| --- | --- |
| `Sources/App.swift` | 菜单、传感器轮询、窗口及生命周期 |
| `Sources/HingeSensor.c` | IOHID 铰链报告读取 |
| `Sources/Capture.swift` | ScreenCaptureKit 桌面捕获 |
| `Sources/CaptureAccess.swift` | 权限状态与错误分类 |
| `Sources/Renderer.swift` | Metal 渲染、模糊和呈现同步 |
| `Sources/Motion.swift` | 角度映射、进度平滑和呈现状态 |
| `Resources/Fold.metal` | 透视、磨砂和渐暗着色器 |
| `Sources/main.swift` | 程序入口与命令行检查 |

## 贡献与致谢

欢迎提交问题与 Pull Request。请参阅 [贡献说明](CONTRIBUTING.md)，报告问题时注明机型、macOS 版本、构建方式与具体错误信息。

- [LidAngleSensor](https://github.com/samhenrigold/LidAngleSensor)：铰链传感器研究参考。
- [iphone-duo-macos-animation](https://github.com/lqSky7/iphone-duo-macos-animation)：视觉效果研究参考。
- [Apple ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit)：桌面捕获文档。

本仓库未打包上述项目的源码、音频或视觉资源。源码采用 [MIT 许可证](LICENSE)。
