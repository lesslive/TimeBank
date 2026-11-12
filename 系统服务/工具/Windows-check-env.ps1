param([switch]$CheckOnly)

# UTF-8 with BOM for Windows PowerShell 5.1.
function Test-Tool {
    param([string]$Command, [string]$Pattern)
    $application = Get-Command $Command -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $application) { return $false }
    try {
        $LASTEXITCODE = 0
        $output = @(& $application.Source --version 2>&1)
        $code = $LASTEXITCODE
        $version = ($output | ForEach-Object { "$_" }) -join "`n"
        return ($code -eq 0 -and $version -match $Pattern)
    } catch {
        return $false
    }
}

function Install-Tool {
    param([string]$Name, [string]$Package)
    if ($CheckOnly) { return $false }
    try {
        $answer = Read-Host "安装或修复 $Name，输入 y 继续，其他输入退出"
    } catch { return $false }
    if ($answer -notmatch '^[yY]$') { return $false }

    $winget = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $winget) {
        Write-Host '❌ 请先从 Microsoft Store 安装或更新「应用安装程序」，重新打开终端后再运行本脚本。'
        Write-Host 'https://apps.microsoft.com/detail/9nblggh4nns1'
        return $false
    }
    try {
        $LASTEXITCODE = 0
        # --force also reinstalls an existing package when its commands are broken.
        & $winget.Source install --id $Package --exact --source winget --force | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ $Name 安装失败（退出码 $LASTEXITCODE），请查看上方提示。"
            return $false
        }
    } catch {
        Write-Host "❌ $Name 安装失败：$_"
        return $false
    }
    # Load newly registered paths without losing session-specific entries.
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath;$env:Path"
    return $true
}

Write-Host '===== LessLive 基础环境检查 ====='
if (-not (Test-Tool git.exe '^git version [0-9]')) {
    Write-Host '❌ Git 未安装或不可用'
    if (-not (Install-Tool Git 'Git.Git')) {
        Write-Host 'Git 安装未完成，已退出。'; exit 1
    }
    if (-not (Test-Tool git.exe '^git version [0-9]')) {
        Write-Host '❌ Git 复核未通过，请重新打开终端再运行脚本。'; exit 1
    }
}
Write-Host '✅ Git 可用'

# npm.cmd avoids an npm.ps1 execution-policy conflict.
if (-not (Test-Tool node.exe '^v[0-9]+\.') -or -not (Test-Tool npm.cmd '^[0-9]+\.')) {
    Write-Host '❌ Node.js 或 npm 未安装或不可用'
    if (-not (Install-Tool 'Node.js（含 npm）' 'OpenJS.NodeJS.LTS')) {
        Write-Host 'Node.js 安装未完成，已退出。'; exit 1
    }
    if (-not (Test-Tool node.exe '^v[0-9]+\.') -or -not (Test-Tool npm.cmd '^[0-9]+\.')) {
        Write-Host '❌ Node.js/npm 复核未通过，请重新打开终端再运行脚本。'; exit 1
    }
}
Write-Host '✅ Node.js 和 npm 可用'
Write-Host "`n✅ 基础环境准备完成，可以继续安装 Agent CLI。"
exit 0
