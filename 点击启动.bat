@echo off
chcp 65001 >nul

set MINERU_MODEL_SOURCE=local
SET MINERU_MODEL_PATH=.\resources\modelscope
SET MODEL_PATH=.\resources\modelscope
SET MINERU_GRADIO_TEMP_DIR=.\Gradio_Temp
SET GRADIO_TEMP_DIR=.\Gradio_Temp
SET GRADIO_UPLOAD_DIR=.\Gradio_Temp

set HTTP_PROXY=
set HTTPS_PROXY=
set http_proxy=
set https_proxy=
set NO_PROXY=127.0.0.1,localhost,::1

set mineru_gradio_port=7860
set max_attempts=10
set attempt=0

:check_port
netstat -ano | findstr :%mineru_gradio_port% >nul
if %errorlevel% == 0 (
    echo 端口 %mineru_gradio_port% 已被占用，尝试使用下一个端口...
    set /a mineru_gradio_port=%mineru_gradio_port%+1
    set /a attempt=%attempt%+1
    if %attempt% leq %max_attempts% (
        goto check_port
    ) else (
        echo 尝试了 %max_attempts% 个端口，均被占用，无法启动服务！
        pause
        exit /b 1
    )
)

echo 正在启动MinerU网页界面...
echo 使用端口: %mineru_gradio_port%
.\PY310\python.exe  .\PY310\Lib\site-packages\mineru\cli\gradio_app.py --server-port %mineru_gradio_port%

@REM .\PY310\python.exe -m pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple
@REM .\PY310\python.exe -m pip install uv -i https://mirrors.aliyun.com/pypi/simple
@REM .\PY310\python.exe -m pip uninstall mineru -y
@REM .\PY310\python.exe -m uv pip install -U "mineru[core]" -i https://mirrors.aliyun.com/pypi/simple
@REM .\PY310\python.exe -m pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu121


@REM .\PY310\python.exe mineru-models-download --model_type all

pause