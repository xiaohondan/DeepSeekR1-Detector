# 企业部署模块
Write-Host "正在部署企业级监控..." -ForegroundColor Cyan

# 创建计划任务
$taskAction = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$PSScriptRoot\detector.bat`""
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 9am
Register-ScheduledTask -TaskName "DeepSeekR1_Monitor" `
    -Action $taskAction -Trigger $taskTrigger `
    -Description "每日DeepSeek服务状态监测" `
    -User "System" -RunLevel Highest

# 添加注册表配置
New-Item -Path "HKLM:\Software\DeepSeek" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\DeepSeek" -Name "EnterpriseMode" -Value 1 -Type DWord

Write-Host "✅ 企业部署完成! 已创建每日监测任务" -ForegroundColor Green