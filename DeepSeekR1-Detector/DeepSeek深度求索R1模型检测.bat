@echo off
chcp 65001 > nul
title DeepSeek R1 服务状态检测工具 v2.2
color 0A

:: ====== 防篡改安全模块 ======
setlocal enabledelayedexpansion
set "security_pass=1"

:: 校验和验证
set "expected_checksum=9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
powershell -command "$hash=(Get-FileHash -LiteralPath '%~f0' -Algorithm SHA256).Hash.ToLower(); [System.IO.File]::WriteAllText('temp_checksum.txt', $hash)" >nul
set /p actual_checksum=<temp_checksum.txt
del temp_checksum.txt

if not "!actual_checksum!"=="!expected_checksum!" (
    echo.
    echo ⚠️ 安全警报：脚本完整性校验失败！
    echo 可能原因：
    echo   - 文件被非法篡改
    echo   - 下载过程中损坏
    echo   - 恶意软件感染
    echo.
    echo 请从官方渠道重新下载：
    echo   https://github.com/你的用户名/你的仓库
    echo.
    echo 技术支持：
    echo   📧 邮箱：xiaohondan@skymail.nik
    echo   🚨 QQ：3815099625
    echo.
    pause
    set "security_pass=0"
)

:: 数字签名验证 (可选扩展)
if exist "%~dp0verify_signature.ps1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0verify_signature.ps1" "%~f0"
    if !errorlevel! neq 0 (
        echo.
        echo ⚠️ 安全警报：数字签名验证失败！
        set "security_pass=0"
    )
)

if !security_pass! equ 0 (
    echo 出于安全考虑，程序已中止运行
    pause
    exit /b 1
)

:: ====== 智能升级模块 ======
set "currentVer=2.2"
set "repoUrl=https://raw.githubusercontent.com/你的用户名/你的仓库/main"

:: 检查更新模式
if "%1"=="/afterupdate" (
    echo 更新完成! 正在启动新版本...
    timeout /t 1 >nul
    goto :MAIN
)

echo.
echo 正在检查智能升级...
set "update_required=0"

:: 安全获取版本信息
powershell -command "$ErrorActionPreference='SilentlyContinue'; $v=(Invoke-WebRequest '%repoUrl%/version.txt' -UseBasicParsing).Content; if($v){[System.IO.File]::WriteAllText('version_new.txt', $v)}" >nul

if exist "version_new.txt" (
    set /p latestVer=<version_new.txt
    del version_new.txt
    
    if "!latestVer!" gtr "!currentVer!" (
        set "update_required=1"
        echo 发现新版本 v!latestVer!，准备安全更新...
    ) else (
        echo 当前已是最新版本 (v%currentVer%)
    )
) else (
    echo 检查更新失败，继续使用当前版本
)

if !update_required! equ 1 (
    echo 正在安全下载更新...
    
    :: 分阶段下载更新
    powershell -command "Invoke-WebRequest '%repoUrl%/detector.bat' -OutFile '%~dp0detector_new.bat'"
    powershell -command "Invoke-WebRequest '%repoUrl%/checksum.txt' -OutFile '%~dp0checksum_new.txt'"
    
    if exist "%~dp0detector_new.bat" (
        echo 正在验证更新完整性...
        
        :: 校验新文件
        set "expected_new_checksum="
        if exist "%~dp0checksum_new.txt" (
            set /p expected_new_checksum=<%~dp0checksum_new.txt
        )
        
        if "!expected_new_checksum!"=="" (
            echo 无法获取校验信息，更新取消
            del "%~dp0detector_new.bat"
            del "%~dp0checksum_new.txt"
            goto :MAIN
        )
        
        powershell -command "$hash=(Get-FileHash -LiteralPath '%~dp0detector_new.bat' -Algorithm SHA256).Hash.ToLower(); [System.IO.File]::WriteAllText('temp_new_checksum.txt', $hash)" >nul
        set /p actual_new_checksum=<temp_new_checksum.txt
        del temp_new_checksum.txt
        
        if not "!actual_new_checksum!"=="!expected_new_checksum!" (
            echo ⚠️ 更新文件校验失败！可能被篡改
            del "%~dp0detector_new.bat"
            del "%~dp0checksum_new.txt"
            goto :MAIN
        )
        
        echo 正在应用安全更新...
        
        :: 创建安全的更新脚本
        echo @echo off > "%~dp0apply_update.bat"
        echo chcp 65001 > nul >> "%~dp0apply_update.bat"
        echo echo 正在安全应用更新... >> "%~dp0apply_update.bat"
        echo timeout /t 1 >nul >> "%~dp0apply_update.bat"
        echo move /y "%~dp0detector_new.bat" "%~f0" ^>nul >> "%~dp0apply_update.bat"
        echo if exist "%~f0" ( >> "%~dp0apply_update.bat"
        echo   echo 更新成功! >> "%~dp0apply_update.bat"
        echo   start "" "%~f0" /afterupdate >> "%~dp0apply_update.bat"
        echo ) else ( >> "%~dp0apply_update.bat"
        echo   echo 更新失败，请重新下载安装 >> "%~dp0apply_update.bat"
        echo   echo 或联系技术支持： >> "%~dp0apply_update.bat"
        echo   echo   - 邮箱：xiaohondan@skymail.nik >> "%~dp0apply_update.bat"
        echo   echo   - QQ：3815099625 >> "%~dp0apply_update.bat"
        echo   pause >> "%~dp0apply_update.bat"
        echo ) >> "%~dp0apply_update.bat"
        echo del "%~dp0checksum_new.txt" ^>nul >> "%~dp0apply_update.bat"
        echo exit >> "%~dp0apply_update.bat"
        
        start "" "%~dp0apply_update.bat"
        exit
    ) else (
        echo 下载更新失败
    )
)

:: ====== 主检测流程 ======
:MAIN
echo.
echo  ██████╗ ███████╗██████╗ ███████╗███████╗██╗  ██╗
echo  ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██║ ██╔╝
echo  ██║  ██║█████╗  ██████╔╝█████╗  ███████╗█████╔╝ 
echo  ██║  ██║██╔══╝  ██╔═══╝ ██╔══╝  ╚════██║██╔═██╗ 
echo  ██████╔╝███████╗██║     ███████╗███████║██║  ██╗
echo  ╚═════╝ ╚══════╝╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝
echo  R1服务AI增强检测 | 深度求索技术驱动 v2.2
echo ===================================================
echo.

:: 网络检测
echo [1/3] 网络智能检测...
ping -n 2 api.deepseek.com >nul
if %errorlevel% equ 0 (
   echo  状态: [√] 网络连接正常
   set netStatus=1
) else (
   echo  状态: [×] 网络连接异常!
   echo  建议: 检查防火墙或DNS设置
   set netStatus=0
)

:: 服务检测
echo.
echo [2/3] R1服务深度检测...
set "curlPath="
where curl >nul 2>nul && set curlPath=1

if defined curlPath (
   echo  检测到curl工具，执行增强分析...
   curl --max-time 5 --head --silent --fail https://chat.deepseek.com >nul
   if %errorlevel% equ 0 (
      echo  状态: [√] R1服务端运行正常
      echo        "钢铁意志，随时待命!"
      set serviceStatus=1
   ) else (
      echo  状态: [!] 服务端响应异常
      set serviceStatus=0
   )
) else (
   echo  状态: [i] 未检测到curl工具
   set serviceStatus=2
)

:: ====== AI增强诊断模块 ======
set "ai_advice="
if %netStatus% equ 0 (
    set "ai_advice=AI诊断: 检测到网络层故障■1.运行网络疑难解答(netsh winsock reset)■2.检查防火墙设置■3.联系网络管理员"
) else if %serviceStatus% equ 0 (
    set "ai_advice=AI诊断: 服务端异常■1.等待5分钟重试■2.访问status.deepseek.com■3.执行系统时间同步(w32tm /resync)"
) else if %serviceStatus% equ 2 (
    set "ai_advice=AI诊断: 需要curl工具■1.按Y自动安装■2.手动下载curl■3.使用基础检测模式"
)

:: ====== 三维报告生成 ======
if not exist "%~dp0report_template.html" (
    echo 正在下载安全报告模板...
    powershell -command "Invoke-WebRequest '%repoUrl%/report_template.html' -OutFile '%~dp0report_template.html'"
)

:: 内置基础报告模板作为后备
if not exist "%~dp0report_template.html" (
    echo 正在创建安全报告模板...
    echo ^<!DOCTYPE html^> > "%~dp0report_template.html"
    echo ^<html^> >> "%~dp0report_template.html"
    echo ^<head^> >> "%~dp0report_template.html"
    echo ^<title^>DeepSeek安全报告^</title^> >> "%~dp0report_template.html"
    echo ^<style^> >> "%~dp0report_template.html"
    echo body{font-family:Arial,sans-serif;margin:20px;background:#f8f9fa;} >> "%~dp0report_template.html"
    echo .container{max-width:800px;margin:0 auto;background:white;padding:20px;border-radius:10px;box-shadow:0 0 10px rgba(0,0,0,0.1);} >> "%~dp0report_template.html"
    echo .header{text-align:center;margin-bottom:20px;border-bottom:2px solid #007bff;padding-bottom:10px;} >> "%~dp0report_template.html"
    echo .status-card{padding:15px;margin:15px 0;border-radius:8px;} >> "%~dp0report_template.html"
    echo .good{background:#d4edda;border-left:4px solid #28a745;} >> "%~dp0report_template.html"
    echo .warn{background:#fff3cd;border-left:4px solid #ffc107;} >> "%~dp0report_template.html"
    echo .bad{background:#f8d7da;border-left:4px solid #dc3545;} >> "%~dp0report_template.html"
    echo .security-alert{background:#fff3e6;border:1px solid #ff9800;padding:10px;border-radius:5px;margin:15px 0;} >> "%~dp0report_template.html"
    echo .contact-section{background:#e8f4f8;padding:15px;border-radius:8px;margin-top:20px;} >> "%~dp0report_template.html"
    echo ^</style^> >> "%~dp0report_template.html"
    echo ^</head^> >> "%~dp0report_template.html"
    echo ^<body^> >> "%~dp0report_template.html"
    echo ^<div class="container"^> >> "%~dp0report_template.html"
    echo ^<div class="header"^> >> "%~dp0report_template.html"
    echo ^<h2^>DeepSeek R1 服务安全报告^</h2^> >> "%~dp0report_template.html"
    echo ^<p^>本报告包含安全验证结果^</p^> >> "%~dp0report_template.html"
    echo ^</div^> >> "%~dp0report_template.html"
    echo ^<div class="status-card %status_class%"^> >> "%~dp0report_template.html"
    echo ^<h3^>服务状态^</h3^> >> "%~dp0report_template.html"
    echo ^<p^>^<strong^>网络连接:^</strong^> %netStatus% (正常:1 异常:0)^</p^> >> "%~dp0report_template.html"
    echo ^<p^>^<strong^>服务状态:^</strong^> %serviceStatus% (正常:1 异常:0 未检测:2)^</p^> >> "%~dp0report_template.html"
    echo ^<p^>^<strong^>检测时间:^</strong^> %date% %time%^</p^> >> "%~dp0report_template.html"
    echo ^<p^>^<strong^>脚本校验:^</strong^> ^<span style="color:green"^>通过^</span^>^</p^> >> "%~dp0report_template.html"
    echo ^</div^> >> "%~dp0report_template.html"
    echo ^<div class="security-alert"^> >> "%~dp0report_template.html"
    echo ^<h3^>安全验证^</h3^> >> "%~dp0report_template.html"
    echo ^<p^>^<strong^>SHA256校验:^</strong^> %actual_checksum%^</p^> >> "%~dp0report_template.html"
    echo ^<p^>此校验码证明本脚本未被篡改，可安全使用^</p^> >> "%~dp0report_template.html"
    echo ^</div^> >> "%~dp0report_template.html"
    echo ^<div^> >> "%~dp0report_template.html"
    echo ^<h3^>AI诊断建议^</h3^> >> "%~dp0report_template.html"
    echo ^<p^>%ai_advice%^</p^> >> "%~dp0report_template.html"
    echo ^</div^> >> "%~dp0report_template.html"
    echo ^<div class="contact-section"^> >> "%~dp0report_template.html"
    echo ^<h3^>技术支持^</h3^> >> "%~dp0report_template.html"
    echo ^<p^>📧 支持邮箱：xiaohondan@skymail.nik^</p^> >> "%~dp0report_template.html"
    echo ^<p^>🌐 社区论坛：^<a href="https://community.deepseek.com"^>https://community.deepseek.com^</a^>^</p^> >> "%~dp0report_template.html"
    echo ^<p^>🚨 QQ紧急热线：3815099625^</p^> >> "%~dp0report_template.html"
    echo ^</div^> >> "%~dp0report_template.html"
    echo ^<button onclick="location.reload()" style="margin-top:15px; padding:10px 20px; background:#007bff; color:white; border:none; border-radius:5px; cursor:pointer;"^>重新检测^</button^> >> "%~dp0report_template.html"
    echo ^</div^> >> "%~dp0report_template.html"
    echo ^</body^> >> "%~dp0report_template.html"
    echo ^</html^> >> "%~dp0report_template.html"
)

set "report_file=DeepSeek_Security_Report_%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%.html"
set "status_class=good"
if %netStatus% neq 1 set "status_class=warn"
if %serviceStatus% equ 0 set "status_class=bad"

(
    for /f "tokens=*" %%i in (%~dp0report_template.html) do (
        set "line=%%i"
        set "line=!line:%%netStatus%%=%netStatus%!"
        set "line=!line:%%serviceStatus%%=%serviceStatus%!"
        set "line=!line:%%status_class%%=%status_class%!"
        set "line=!line:%%ai_advice%%=%ai_advice:\n=<br>%!"
        set "line=!line:%%actual_checksum%%=%actual_checksum%!"
        echo !line!
    )
) > "%report_file%"

:: ====== 显示结果 ======
echo.
echo ================= 安全检测报告 =================
echo 脚本校验: 通过 (SHA256: %actual_checksum:~0,12%...)
if defined ai_advice (
    for /f "tokens=1* delims=■" %%a in ("!ai_advice!") do (
        echo %%a
        for %%c in (%%b) do echo   - %%c
    )
)
echo.
echo 安全报告已生成: %report_file%
echo.

:: ====== 增强用户选项 ======
echo 安全选项:
echo  [1] 打开安全报告
echo  [2] 验证脚本完整性
echo  [3] 安装curl工具
echo  [4] 企业部署模式
echo  [5] 联系技术支持
echo  [6] 退出
echo.

choice /c 123456 /n /m "请选择:"
if %errorlevel% equ 1 (
    start "" "%report_file%"
    goto :EOF
)
if %errorlevel% equ 2 (
    echo.
    echo ============= 脚本完整性验证 =============
    echo 当前校验码: %actual_checksum%
    echo 预期校验码: %expected_checksum%
    echo.
    if "%actual_checksum%"=="%expected_checksum%" (
        echo ✅ 验证通过! 脚本未被篡改
    ) else (
        echo ⚠️ 验证失败! 文件可能被修改
    )
    echo.
    pause
    goto :MAIN
)
if %errorlevel% equ 3 (
    start "" "https://curl.se/windows/dl-8.8.0_6/curl-8.8.0_6-win64-mingw.zip"
    goto :EOF
)
if %errorlevel% equ 4 (
    if exist "%~dp0enterprise_deploy.ps1" (
        powershell -ExecutionPolicy Bypass -File "%~dp0enterprise_deploy.ps1"
    ) else (
        echo 正在下载安全企业部署模块...
        powershell -command "Invoke-WebRequest '%repoUrl%/enterprise_deploy.ps1' -OutFile '%~dp0enterprise_deploy.ps1'"
        if exist "%~dp0enterprise_deploy.ps1" (
            powershell -ExecutionPolicy Bypass -File "%~dp0enterprise_deploy.ps1"
        )
    )
)
if %errorlevel% equ 5 (
    echo.
    echo ================ 技术支持渠道 ================
    echo.
    echo  📧 支持邮箱：xiaohondan@skymail.nik
    echo.
    echo  🌐 社区论坛：https://community.deepseek.com
    echo.
    echo  🚨 QQ紧急热线：3815099625
    echo.
    echo 我们将竭诚为您服务！
    echo.
    pause
)