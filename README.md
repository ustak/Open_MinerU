# MinerU 2.6.6 修改版同步项目

本仓库包含对 MinerU 项目核心代码（`markdown_parser.py` 等）的优化和修改。由于项目运行环境（16GB+）过大，仓库仅同步了核心代码和配置文件。

## 🚀 如何复现环境

如果你要在新机器上恢复此项目，请按以下步骤操作：

### 1. 准备基础环境
建议使用 Python 3.10 或更高版本。
```bash
# 创建并激活环境（如果你不使用本项目自带的 PY310）
python -m venv venv
source venv/bin/activate  # Linux/Mac
.\venv\Scripts\activate     # Windows
```

### 2. 安装依赖
```bash
pip install -r requirements.txt
```

### 3. 下载模型权重 (ModelScope)
本项目依赖以下模型，请从 ModelScope 下载并放置在对应目录下：

| 模型名称 | 存放路径 | 下载地址 |
| :--- | :--- | :--- |
| PDF-Extract-Kit | `resources/modelscope/hub/models/OpenDataLab/PDF-Extract-Kit-1___0` | [ModelScope](https://modelscope.cn/models/OpenDataLab/PDF-Extract-Kit) |
| MinerU VLM | `resources/modelscope/hub/models/OpenDataLab/MinerU2___5-2509-1___2B` | [ModelScope](https://modelscope.cn/models/OpenDataLab/MinerU2.5) |

> **注意**：请确保 `mineru.json` 中的 `models-dir` 路径与实际存放位置一致。

### 4. 应用核心代码修改
这是最关键的一步。由于本仓库追踪的是 `PY310/Lib/site-packages/mineru/` 下的代码，当你重新安装 mineru 库后，需要确保使用仓库中的文件覆盖掉 site-packages 里的同名文件。

如果你保持了本仓库的目录结构，可以直接运行项目。

## 📂 目录结构说明
- `PY310/Lib/site-packages/mineru/`: 包含修改过的核心代码（如翻译、解析逻辑）。
- `mineru.json`: 配置文件，包含 API Key 和 模型路径。
- `点击启动.bat`: Windows 下的一键启动脚本。
- `requirements.txt`: 完整的环境依赖清单。

## 🛠️ 已知修改点
- 修改了 `markdown_parser.py` 以解决翻译后的换行和格式问题。
- 自定义了翻译占位符保护机制。
