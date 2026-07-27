# MinerU 2.6.6 Windows 优化版 (一键启动版)

## 版本信息

| 组件 | 版本 |
| :--- | :--- |
| MinerU | 2.6.6 |
| 配置文件 (config_version) | 1.3.1 |
| Pipeline 模型 (PDF-Extract-Kit) | 1.0 |
| VLM 模型 (MinerU2.5) | 2509-1.2B |

本项目主页：[https://github.com/ustak/Open_MinerU](https://github.com/ustak/Open_MinerU)

本项目是基于 [OpenDataLab/MinerU](https://github.com/opendatalab/MinerU) 的深度优化版本，专为 Windows 环境设计。我们集成了 Python 嵌入式运行环境，并针对 PDF 解析和翻译逻辑进行了核心改进。

> [!IMPORTANT]
> **开源协议说明**：本项目基于 **AGPL-3.0** 协议开源。由于原项目 MinerU 采用 AGPL-3.0，本项目及其所有衍生代码必须同样遵守该协议。

---

## 🚀 如何复现完整项目

由于本项目使用嵌入式 Python 结构，复现时需要将代码“注入”到基础运行环境中。

### 1. 获取基础运行环境

你有两种方式恢复运行环境：

* **方式 A（推荐）**：下载官方 MinerU 一键启动包，解压后将本仓库的所有文件直接覆盖进去。
* **方式 B（纯净版）**：下载 [Python 3.10 嵌入式版](https://www.python.org/downloads/windows/)，解压到 `PY310` 文件夹，并根据 `requirements.txt` 安装依赖。

### 2. 补全模型权重

请按照以下结构放置从 [ModelScope](https://modelscope.cn/organization/OpenDataLab) 下载的模型：

| 模型名称 | 存放路径 |
| :--- | :--- |
| PDF-Extract-Kit | `resources/modelscope/hub/models/OpenDataLab/PDF-Extract-Kit-1___0` |
| MinerU VLM | `resources/modelscope/hub/models/OpenDataLab/MinerU2___5-2509-1___2B` |

### 3. 一键启动

环境和模型准备好后，直接双击根目录的：
`点击启动.bat`

---

## 📂 仓库代码结构 (核心修改点)

本项目仓库仅包含核心源码和配置，**不包含** 巨大的运行环境和模型权重。本仓库的代码结构严格对应嵌入式路径，确保覆盖即生效：

* **`PY310/Lib/site-packages/mineru/`**: 包含我们修改过的核心源码。修改后的核心逻辑位于 `cli/markdown_parser.py`（实现了增强的公式保护和翻译还原逻辑）。
* **`mineru.json`**: 核心配置文件（已配置好模型本地路径）。
* **`点击启动.bat`**: 自动检测端口并启动 Gradio 服务的脚本。

---

## 🛠️ 技术细节与核心改进

相比于原始版本，本项目在以下方面进行了深度定制和优化：

1. **翻译逻辑增强**：优化了 `markdown_parser.py`，解决了 Markdown 文本在翻译（如使用 LLM 辅助）后出现的结构混乱、嵌套丢失等问题。
2. **公式保护机制**：引入了基于占位符的 LaTeX 公式保护技术，确保 `$$ ... $$` 和 `$ ... $` 公式在翻译过程中不被破坏或误改。
3. **Windows 端口自适应**：增强了启动脚本 `点击启动.bat`，能够自动检测并寻找可用端口（默认 8081），避免端口冲突导致启动失败。
4. **免安装一键运行**：针对 Windows 用户优化，支持直接解压运行，无需复杂系统环境配置。
5. **离线权重适配**：预置了本地模型路径配置，支持在断网环境下稳定运行。

---

## 📜 开源协议与版权声明 (License)

本项目采用 **AGPL-3.0 (GNU Affero General Public License v3.0)**。

### 归属与致谢 (Acknowledgement)

本项目深深感谢 **OpenDataLab** 团队开发的原始 [MinerU](https://github.com/opendatalab/MinerU) 项目。

如果您在研究中使用了本项目或原始 MinerU，请按以下格式引用：

```bibtex
@misc{niu2025mineru25decoupledvisionlanguagemodel,
      title={MinerU2.5: A Decoupled Vision-Language Model for Efficient High-Resolution Document Parsing}, 
      author={Junbo Niu and Others},
      year={2025},
      eprint={2509.22186},
      archivePrefix={arXiv},
      primaryClass={cs.CV},
      url={https://arxiv.org/abs/2509.22186}, 
}

@misc{wang2024mineruopensourcesolutionprecise,
      title={MinerU: An Open-Source Solution for Precise Document Content Extraction}, 
      author={Bin Wang and Others},
      year={2024},
      eprint={2409.18839},
      archivePrefix={arXiv},
      primaryClass={cs.CV},
      url={https://arxiv.org/abs/2409.18839}, 
}
```

---

## ⚠️ 贡献与反馈

本项目仅供学习与技术交流。如有任何改进建议或 Bug 反馈，请在 [本仓库提交 Issue](https://github.com/ustak/Open_MinerU/issues)。针对模型本身的问题，请直接咨询原作者。
