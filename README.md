
# Voice2Type

语音输入工具 — 按下热键说话，松手自动转文字。基于 faster-whisper 本地模型，离线运行，无网络依赖。

系统托盘运行，`Ctrl+Shift+V` 开始录音，松手自动识别并粘贴。

## 功能

- **按下说话** — 按下热键开始录音，松手自动转文字
- **本地模型** — 基于 faster-whisper，模型下载后完全离线运行
- **中文优化** — 默认中文模型，自动繁体转简体
- **系统托盘** — 后台驻留托盘，图标实时显示状态（待命/录音中/识别中）
- **自动粘贴** — 识别结果自动模拟 Ctrl+V 粘贴到当前光标位置
- **兼容国内网络** — 默认使用 HuggingFace 镜像 hf-mirror.com

## 安装

```bash
# 1. 安装 Python 3.10+
# 2. 创建虚拟环境并安装依赖
python -m venv .venv
.venv\Scripts\activate
pip install -r voice2type\requirements.txt

# 3. 首次运行会下载 whisper 模型（约 500MB）
#    运行后出现在系统托盘，按 Ctrl+Shift+V 使用
.\start_voice2type.ps1
```

也可直接运行 `install.ps1` 自动完成上述步骤。

## 使用方法

| 操作 | 方式 |
|---|---|
| 开始录音 | 按下 `Ctrl+Shift+V` |
| 停止并识别 | 松开 `Ctrl+Shift+V` |
| 退出 | 托盘右键菜单 → 退出 |

## 配置

配置文件位于 `~/.voice2type/config.json`：

```json
{
  "hotkey": "ctrl+shift+v",
  "model_size": "medium",
  "device": "auto",
  "language": "zh",
  "autostart": false
}
```

可选项：`model_size` 支持 `tiny` / `base` / `small` / `medium` / `large-v3`（越大越准但越慢）。

## 技术栈

- **Python** — 桌面应用
- **faster-whisper** — CTranslate2 加速的 Whisper 语音识别
- **sounddevice** — 音频录制
- **keyboard** — 全局热键监听
- **pystray** — 系统托盘图标
- **pyperclip** — 剪贴板操作

## 项目结构

```
voice2type/
├── main.py               # 应用入口，托盘 + 热键 + 生命周期管理
├── recorder.py           # 音频录制 + 热键监听
├── transcriber.py        # faster-whisper 语音识别
├── typer.py              # 模拟键盘粘贴
├── config.py             # 配置管理
├── requirements.txt      # Python 依赖
├── assets/               # 图标资源
├── start_voice2type.ps1  # 启动脚本
└── install.ps1           # 安装脚本
```
