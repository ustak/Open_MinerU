# MinerU 2.6.6 修改版同步项目

本项目是一个基于 **Python 嵌入式版本** 的一键启动包优化版。仓库仅同步核心源码和配置，不包含 16GB 的运行环境和模型权重。

## 🚀 如何复现完整项目

由于本项目使用嵌入式 Python 结构，复现时需要将代码“注入”到基础运行环境中。

### 1. 获取基础运行环境
你有两种方式恢复运行环境：

*   **方式 A（推荐）**：下载官方 MinerU 一键启动包，解压后将本仓库的所有文件直接覆盖进去。
*   **方式 B（纯净版）**：下载 [Python 3.10 嵌入式版](https://www.python.org/downloads/windows/)，解压到 `PY310` 文件夹，并根据 `requirements.txt` 安装依赖。

### 2. 补全模型权重
请下载以下模型并放置在 `resources` 对应的目录下：

| 模型名称 | 存放路径 |
| :--- | :--- |
| PDF-Extract-Kit | `resources/modelscope/hub/models/OpenDataLab/PDF-Extract-Kit-1___0` |
| MinerU VLM | `resources/modelscope/hub/models/OpenDataLab/MinerU2___5-2509-1___2B` |

> 具体的下载链接请参考 [ModelScope](https://modelscope.cn/organization/OpenDataLab)。

### 3. 一键启动
环境和模型准备好后，直接双击根目录的：
`点击启动.bat`

---

## 📂 仓库代码结构 (核心修改点)

本仓库的代码结构严格对应嵌入式路径，确保覆盖即生效：

*   **`PY310/Lib/site-packages/mineru/`**: 包含我们修改过的核心源码（如翻译逻辑优化、公式保护、换行修复等）。
*   **`mineru.json`**: 核心配置文件（已配置好模型本地路径）。
*   **`点击启动.bat`**: 自动检测端口并启动 Gradio 服务的脚本。

## 🛠️ 修改说明
1.  **翻译逻辑增强**：优化了 `markdown_parser.py`，解决了 Markdown 翻译后结构混乱、公式丢失的问题。
2.  **公式保护机制**：引入了占位符保护，确保 LaTeX 公式在翻译过程中不被损坏。
3.  **Windows 端口自适应**：启动脚本会自动检测并避开已被占用的端口。

---

## ⚠️ 开发注意
如果你修改了代码包以外的其他第三方库，或者增加了新的二进制依赖，请记得更新 `.gitignore` 或联系维护者。
