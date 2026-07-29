# 便携式 MinerU 部署和踩坑指南

> 本文档记录了将 MinerU 3.4.4 打包成便携式版本的完整过程，包括所有遇到的问题和解决方案。
> 
> 最后更新：2026-07-27

---

## 目录

1. [项目概述](#1-项目概述)
2. [系统要求](#2-系统要求)
3. [项目结构](#3-项目结构)
4. [部署步骤](#4-部署步骤)
   - [4.1 下载嵌入式 Python](#41-下载嵌入式-python)
   - [4.2 安装构建工具](#42-安装构建工具)
   - [4.3 安装 MinerU 核心依赖](#43-安装-mineru-核心依赖)
   - [4.4 安装 PyTorch CUDA 版本](#44-安装-pytorch-cuda-版本)
   - [4.5 安装 pipeline 依赖](#45-安装-pipeline-依赖)
   - [4.6 安装 lmdeploy 依赖](#46-安装-lmdeploy-依赖)
   - [4.7 安装 Gradio (WebUI)](#47-安装-gradio-webui)
   - [4.8 安装 CUDA Toolkit](#48-安装-cuda-toolkit)
   - [4.9 下载模型](#49-下载模型)
   - [4.10 配置模型路径](#410-配置模型路径)
5. [配置文件说明](#5-配置文件说明)
6. [启动脚本](#6-启动脚本)
7. [踩坑记录](#7-踩坑记录)
8. [常见问题](#8-常见问题)
9. [参考资料](#9-参考资料)

---

## 1. 项目概述

### 什么是 MinerU？

MinerU 是一个文档解析工具，支持将 PDF、图片、DOCX、PPTX、XLSX 转换为 Markdown 和 JSON 格式。

### 三种推理后端

| 后端 | 说明 | 依赖 |
|------|------|------|
| **pipeline** | 传统 ONNX 推理，稳定可靠 | torch, torchvision, transformers, onnxruntime |
| **vlm-engine** | VLM 引擎，高性能 | lmdeploy (Windows) 或 vllm (Linux) |
| **hybrid-engine** | 混合引擎，结合两者 | 以上两者 |

### 为什么需要便携式？

- 无需在目标机器上安装 Python 和依赖
- 开箱即用，复制文件夹即可运行
- 避免环境污染

---

## 2. 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Windows 10/11 64位 |
| GPU | NVIDIA GPU，建议 8GB+ 显存 |
| 磁盘空间 | 约 15GB |
| Python | 3.10 - 3.13 (本文档使用 3.12) |
| CUDA Toolkit | 12.4 (lmdeploy turbomind 后端需要) |
| 网络 | 需要下载依赖和模型 |

---

## 3. 项目结构

```
MinerU_3.4.4/
├── PY312/                     # 嵌入式 Python 3.12 + 所有依赖
│   ├── python.exe
│   ├── Scripts/              # pip, mineru 等命令
│   └── Lib/site-packages/    # 所有依赖包（含 mineru）
│
├── models/                    # 模型文件
│   ├── models/               # Pipeline 模型（下载后无需改名）
│   │   ├── Layout/           # 布局检测模型
│   │   ├── MFR/              # 公式识别模型
│   │   ├── OCR/              # OCR 模型
│   │   ├── TabCls/           # 表格分类模型
│   │   └── TabRec/           # 表格识别模型
│   └── VLM/                  # VLM 模型
│
├── scripts/                   # 脚本
│   ├── 1_init_env.bat        # 初始化环境（下载Python、安装pip）
│   └── start_mineru.bat      # 启动 WebUI
│
└── docs/                      # 文档
    └── 便携式MinerU部署和踩坑指南.md

可选：
├── MinerU/                    # MinerU 源码（仅供参考，非必需）
└── packages/                  # 安装包（安装后可删除）
    ├── CUDA Toolkit 12.4/    # CUDA 安装包
    └── pytorch/              # PyTorch wheel 文件
```

**最小便携包**：只需 `PY312`、`models`、`scripts` 三个文件夹即可运行。

---

## 4. 部署步骤

### 4.1 下载嵌入式 Python

**支持的 Python 版本**：3.10, 3.11, 3.12, 3.13

下载 Python 3.12.9 嵌入式版本：
```
https://www.python.org/ftp/python/3.12.9/python-3.12.9-embed-amd64.zip
```

**配置步骤**：

1. 解压到 `PY312` 目录
2. 修改 `python312._pth` 文件，将 `#import site` 改为 `import site`
3. 安装 pip：
   ```bash
   # 下载 get-pip.py
   curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
   
   # 安装 pip
   PY312\python.exe get-pip.py --no-warn-script-location --no-cache-dir
   ```

### 4.2 安装构建工具

```bash
PY312\python.exe -m pip install --no-cache-dir wheel setuptools
```

**原因**：嵌入式 Python 默认没有 setuptools，无法安装需要构建的包。

### 4.3 安装 MinerU 核心依赖

```bash
# 设置代理（如果需要）
set HTTP_PROXY=http://127.0.0.1:7897
set HTTPS_PROXY=http://127.0.0.1:7897

# 安装 MinerU
PY312\python.exe -m pip install --no-cache-dir -e MinerU
```

**核心依赖包括**：
- click, loguru, numpy, tqdm
- requests, httpx, pillow
- pypdfium2, pypdf, reportlab
- modelscope, huggingface-hub
- opencv-python, fastapi, uvicorn

### 4.4 安装 PyTorch CUDA 版本

**重要**：需要安装 CUDA 版本的 PyTorch，否则无法使用 GPU 加速。

**下载地址**：
```
https://download.pytorch.org/whl/cu124/torch-2.6.0%2Bcu124-cp312-cp312-win_amd64.whl
https://download.pytorch.org/whl/cu124/torchvision-0.21.0%2Bcu124-cp312-cp312-win_amd64.whl
```

**安装命令**：
```bash
PY312\python.exe -m pip install --no-cache-dir torch-2.6.0+cu124-cp312-cp312-win_amd64.whl
PY312\python.exe -m pip install --no-cache-dir torchvision-0.21.0+cu124-cp312-cp312-win_amd64.whl
```

**踩坑**：
- pip 直接下载可能因为网络问题中断
- 建议用浏览器下载 wheel 文件后本地安装
- 国内镜像源（清华、阿里云）没有 cu124 版本

**验证**：
```python
import torch
print(torch.__version__)  # 应显示 2.6.0+cu124
print(torch.cuda.is_available())  # 应显示 True
```

### 4.5 安装 pipeline 依赖

```bash
PY312\python.exe -m pip install --no-cache-dir ^
    PyYAML ^
    ftfy ^
    shapely ^
    pyclipper ^
    "transformers>=4.57.3,<5.0.0" ^
    "safetensors>=0.4.0,<1" ^
    "onnxruntime>1.17.0"
```

### 4.6 安装 lmdeploy 依赖

```bash
PY312\python.exe -m pip install --no-cache-dir ^
    "lmdeploy>=0.10.2,<0.12" ^
    "qwen-vl-utils>=0.0.14,<1"
```

**踩坑**：
- lmdeploy 的 turbomind 后端需要 CUDA Toolkit
- Windows 上如果没有 CUDA Toolkit，需要使用 pytorch 后端
- 设置环境变量 `MINERU_LMDEPLOY_BACKEND=pytorch` 可切换后端

### 4.7 安装 Gradio (WebUI)

```bash
PY312\python.exe -m pip install --no-cache-dir ^
    "gradio>=5.49.1,<6.9.0" ^
    "gradio-pdf>=0.0.22"
```

### 4.8 安装 CUDA Toolkit

**为什么需要？**
- lmdeploy 的 turbomind 后端需要 CUDA Toolkit 来编译
- turbomind 比 pytorch 后端性能更好

**下载地址**：
```
https://developer.nvidia.com/cuda-12-4-0-download-archive
```

**安装选项**：
- 选择 Windows > x86_64 > 10 > exe (local)
- 自定义安装，勾选 CUDA Development 和 CUDA Runtime

**验证**：
```bash
nvcc --version
echo %CUDA_PATH%  # 应显示 C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.4
```

### 4.9 下载模型

**模型来源**：
- Pipeline: [OpenDataLab/PDF-Extract-Kit-1.0](https://modelscope.cn/models/OpenDataLab/PDF-Extract-Kit-1.0)
- VLM: [OpenDataLab/MinerU2.5-Pro-2605-1.2B](https://modelscope.cn/models/OpenDataLab/MinerU2.5-Pro-2605-1.2B)

**重要**：下载下来的 Pipeline 模型文件夹就叫 `models`，**不要改名**！

MinerU 代码会自动拼接路径：`配置路径` + `models/OCR/...`

所以下载后保持原始文件夹名称即可，最终结构：
```
models/
├── models/     # Pipeline 模型（下载后就是这个名字）
│   ├── Layout/
│   ├── MFR/
│   ├── OCR/
│   ├── TabCls/
│   └── TabRec/
└── VLM/        # VLM 模型
```

### 4.10 配置模型路径

在用户目录创建 `mineru.json`：

```json
{
    "latex-delimiter-config": {
        "display": {
            "left": "$$",
            "right": "$$"
        },
        "inline": {
            "left": "$",
            "right": "$"
        }
    },
    "models-dir": {
        "pipeline": "C:\\Users\\jinta\\Documents\\My_Project_Open\\MinerU_3.4.4\\models",
        "vlm": "C:\\Users\\jinta\\Documents\\My_Project_Open\\MinerU_3.4.4\\models\\VLM"
    },
    "model-source": "local",
    "config_version": "1.3.2"
}
```

**踩坑**：
- `pipeline` 路径应该指向 `models` 目录，而不是 `models/models`
- 路径分隔符需要用 `\\` 或 `/`
- 下载下来的 Pipeline 模型文件夹就叫 `models`，无需改名！

---

## 5. 配置文件说明

### mineru.json 配置项

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `models-dir.pipeline` | pipeline 模型路径 | `"C:\\...\\models"` |
| `models-dir.vlm` | VLM 模型路径 | `"C:\\...\\models\\VLM"` |
| `model-source` | 模型来源 | `"local"` |
| `latex-delimiter-config` | LaTeX 分隔符配置 | 见上文 |
| `llm-aided-config` | LLM 辅助配置 | 可选 |

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `MINERU_MODEL_SOURCE` | 模型来源 | `auto` |
| `MINERU_LMDEPLOY_BACKEND` | lmdeploy 后端 | `turbomind` |
| `CUDA_PATH` | CUDA 路径 | 系统自动设置 |

---

## 6. 启动脚本

### start_mineru.bat

```batch
@echo off
setlocal
cd /d "%~dp0\.."

set "PY_DIR=PY312"
set "MINERU_MODEL_SOURCE=local"
set "HTTP_PROXY="
set "HTTPS_PROXY="
set "NO_PROXY=localhost,127.0.0.1"

echo ================================
echo  Starting MinerU WebUI
echo ================================
echo.
echo URL: http://127.0.0.1:7860
echo Backend: lmdeploy turbomind
echo.

"%PY_DIR%\Scripts\mineru-gradio.exe" --server-name 127.0.0.1 --server-port 7860 --max-convert-pages 9999
pause
```

**说明**：
- 清除代理设置，避免 localhost 访问问题
- 设置 `MINERU_MODEL_SOURCE=local` 使用本地模型
- 如果没有 CUDA Toolkit，添加 `set "MINERU_LMDEPLOY_BACKEND=pytorch"`

**修改「最大转换页数」上限**：

WebUI 中的「最大转换页数」滑块上限由启动参数 `--max-convert-pages` 决定，**默认值 1000**。这是官方在 CLI/WebUI 提交层设置的默认护栏（用于避免一次性提交超大任务导致内存/显存溢出），**不是**底层解析引擎的能力上限——真正的推理引擎（vllm/lmdeploy）并不感知这个限制，API 层的 `end_page_id` 默认是 99999。

如果文档超过 1000 页（例如 4000 多页），只需在启动命令后追加该参数并把数值调大，如上面的 `--max-convert-pages 9999`：

- 修改后**重启 WebUI**，「最大转换页数」滑块的最大值和默认值都会变成你设定的数值（如 9999），可直接拖到顶一次性转换整本文档。
- 即使设定的数值大于文档实际页数也**不会报错**，API 会自动把结束页裁到真实页数。
- **识别精度不受影响**：MinerU 是逐页独立识别的，单页质量与批次大小无关；放大上限不会降低识别精度。真正的风险是**稳定性**——超大任务可能因内存/显存不足而整任务失败（官方建议约 600 页需准备约 32G 可用内存），WebUI 还会把整本 Markdown + 预览 PDF 塞进浏览器标签页导致卡顿甚至崩溃。
- 若机器内存/显存有限、担心中途失败，推荐改用命令行分段处理（WebUI 不能设起始页，只能从第 0 页起设上限）：

  ```bash
  PY312\Scripts\mineru.exe -p input.pdf -o output --start 0 --end 999
  PY312\Scripts\mineru.exe -p input.pdf -o output --start 1000 --end 1999
  # ……依此类推，每批几百页通常较稳
  ```

  也可在启动前设置环境变量降低 OOM 风险：`set "MINERU_VIRTUAL_VRAM_SIZE=10"`、`set "MINERU_PDF_RENDER_TIMEOUT=1800"`。

### 其他启动方式

```bash
# 命令行解析
PY312\Scripts\mineru.exe -p input.pdf -o output

# API 服务
PY312\Scripts\mineru-api.exe --host 0.0.0.0 --port 8000

# WebUI
PY312\Scripts\mineru-gradio.exe --server-name 0.0.0.0 --server-port 7860
```

---

## 7. 踩坑记录

### 7.1 网络问题

**问题**：pip 下载超时或中断

**解决方案**：
1. 使用 VPN 的 TUN 模式
2. 手动下载 wheel 文件后本地安装
3. 使用 `--no-cache-dir` 避免缓存问题

### 7.2 代理导致 localhost 访问失败

**问题**：Gradio 启动时报错 `Couldn't start the app because 'http://localhost:7860/gradio_api/startup-events' failed`

**解决方案**：在启动脚本中清除代理设置
```batch
set "HTTP_PROXY="
set "HTTPS_PROXY="
set "NO_PROXY=localhost,127.0.0.1"
```

### 7.3 CUDA Toolkit 缺失

**问题**：lmdeploy 报错 `Can not find $env:CUDA_PATH`

**解决方案**：
1. 安装 CUDA Toolkit 12.4
2. 或者使用 pytorch 后端：`set "MINERU_LMDEPLOY_BACKEND=pytorch"`

### 7.4 Triton 缺失

**问题**：lmdeploy pytorch 后端报错 `ModuleNotFoundError: No module named 'triton'`

**解决方案**：
- Triton 在 Windows 上支持有限
- 建议安装 CUDA Toolkit 使用 turbomind 后端
- 或者只使用 pipeline 后端

### 7.5 模型路径错误

**问题**：`FileNotFoundError: ... is not existed.`

**原因**：MinerU 代码中的路径拼接逻辑：
- 配置的 `models-dir` + `models/OCR/paddleocr_torch`
- 最终路径：`models/models/OCR/...`

**解决方案**：
- 下载下来的 Pipeline 模型文件夹就叫 `models`，**不要改名**！
- 配置文件中 `pipeline` 路径指向 `models` 目录的父目录

### 7.6 PyTorch CPU 版本

**问题**：`CUDA available: False`

**原因**：安装了 CPU 版本的 PyTorch

**解决方案**：下载并安装 CUDA 版本的 wheel 文件

### 7.7 批处理文件编码问题

**问题**：bat 文件中的中文或特殊字符导致解析错误

**解决方案**：
- 使用简单的英文字符
- 避免在 bat 文件中使用括号和特殊符号
- 或者使用 PowerShell 脚本

---

## 8. 常见问题

### Q1: 如何检查 CUDA 是否可用？

```bash
PY312\python.exe -c "import torch; print(torch.cuda.is_available())"
```

### Q2: 如何切换推理后端？

在 WebUI 界面中选择：
- **pipeline**: 稳定，不需要 CUDA Toolkit
- **hybrid-engine**: 高性能，需要所有依赖

### Q3: 如何查看日志？

启动时会显示详细日志，包括：
- 使用的后端类型
- 模型加载时间
- 错误信息

### Q4: 如何更新 MinerU？

```bash
PY312\python.exe -m pip install --no-cache-dir --upgrade mineru
```

或者如果有本地源码：
```bash
PY312\python.exe -m pip install --no-cache-dir -e MinerU
```

### Q5: 如何添加更多模型？

将模型文件放到对应的目录：
- Pipeline 模型：`models/models/`（注意是两层 models）
- VLM 模型：`models/VLM/`

### Q6: 便携式版本可以在其他电脑上使用吗？

可以，但需要确保：
1. 目标电脑有 NVIDIA GPU
2. 安装了对应的 CUDA 驱动
3. 如果使用 turbomind 后端，需要安装 CUDA Toolkit

### Q7: WebUI 的「最大转换页数」为什么是 1000？想转更大的文档怎么办？

默认 1000 是官方在 `--max-convert-pages` 参数上设的默认值，属于 CLI/WebUI 提交层的护栏，不是引擎能力上限。如需转换超过 1000 页的文档：

1. 编辑 `scripts/2_start_mineru.bat`，在 `mineru-gradio.exe` 启动命令后追加 `--max-convert-pages <数值>`（例如 `--max-convert-pages 9999`）。
2. 重启 WebUI，滑块上限与默认值即变为该数值，可直接拖到顶一次性转换整本文档。
3. 精度不受放大上限影响；但超大任务有内存/显存溢出导致整任务失败的风险。若机器配置有限，建议用命令行 `--start/--end` 分段处理（详见第 6 节说明）。

---

## 9. 参考资料

- [MinerU 官方仓库](https://github.com/opendatalab/MinerU)
- [MinerU 官方文档](https://opendatalab.github.io/MinerU/)
- [PyTorch 官网](https://pytorch.org/)
- [CUDA Toolkit 下载](https://developer.nvidia.com/cuda-downloads)
- [lmdeploy 文档](https://lmdeploy.readthedocs.io/)

---

## 附录：快速部署检查清单

- [ ] 下载并配置嵌入式 Python 3.12
- [ ] 安装 wheel 和 setuptools
- [ ] 安装 MinerU 核心依赖
- [ ] 下载并安装 PyTorch CUDA 版本 (torch-2.6.0+cu124)
- [ ] 下载并安装 torchvision CUDA 版本
- [ ] 安装 pipeline 依赖
- [ ] 安装 lmdeploy 依赖
- [ ] 安装 Gradio
- [ ] 安装 CUDA Toolkit 12.4（可选，用于 turbomind 后端）
- [ ] 下载模型文件（保持原始文件夹名称 `models`）
- [ ] 创建 mineru.json 配置文件
- [ ] 测试启动 WebUI
- [ ] 测试文档解析功能

---

**文档作者**：opencode  
**创建日期**：2026-07-27  
**版本**：1.0
