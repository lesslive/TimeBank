#!/bin/bash
# Compatible with macOS Bash 3.2.
set -o pipefail

check_only=false
case "${1:-}" in
    --check-only) check_only=true ;;
    '') ;;
    *) printf '用法：bash macOS-check-env.sh [--check-only]\n'; exit 2 ;;
esac

confirm() {
    local answer
    "$check_only" && return 1
    read -r -p "$1，输入 y 继续，其他输入退出：" answer || return 1
    [[ "$answer" = y || "$answer" = Y ]]
}

usable() {
    local output
    output=$("$1" --version 2>&1) && [[ "$output" =~ $2 ]]
}

find_brew() {
    local candidate
    if command -v brew >/dev/null 2>&1; then
        brew_bin=$(command -v brew)
        return 0
    fi
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$candidate" ]; then
            brew_bin="$candidate"
            return 0
        fi
    done
    return 1
}

printf '===== LessLive 基础环境检查 =====\n'
brew_bin=''
configure_brew=false
command -v brew >/dev/null 2>&1 || configure_brew=true
if ! find_brew; then
    printf '❌ 未安装 Homebrew\n'
    if ! confirm '安装 Homebrew'; then
        printf '已退出。\n'; exit 1
    fi
    # Do not execute an empty/partial installer if the download fails.
    if ! installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) || [ -z "$installer" ]; then
        printf '❌ Homebrew 安装程序下载失败，请重新运行脚本。\n'; exit 1
    fi
    if ! /bin/bash -c "$installer"; then
        printf '❌ Homebrew 安装失败，请查看上方提示后重新运行脚本。\n'; exit 1
    fi
    if ! find_brew; then
        printf '❌ 未找到安装后的 Homebrew，请按安装器提示配置后重新运行脚本。\n'; exit 1
    fi
fi
if ! usable "$brew_bin" '^Homebrew [0-9]'; then
    printf '❌ Homebrew 运行异常，请查看 brew --version 的结果。\n'; exit 1
fi
if ! brew_env=$("$brew_bin" shellenv) || ! eval "$brew_env"; then
    printf '❌ Homebrew 环境加载失败。\n'; exit 1
fi
# Persist the installer setup for future terminals, only when brew was off PATH.
if "$configure_brew" && ! "$check_only"; then
    case "${SHELL:-/bin/zsh}" in
        */bash) profile="$HOME/.bash_profile" ;;
        *) profile="$HOME/.zprofile" ;;
    esac
    printf -v setup_line 'eval "$(%q shellenv)"' "$brew_bin"
    if ! grep -Fqx "$setup_line" "$profile" 2>/dev/null; then
        if ! printf '\n%s\n' "$setup_line" >> "$profile"; then
            printf '❌ 无法保存 Homebrew 配置到 %s。\n' "$profile"; exit 1
        fi
    fi
fi
printf '✅ Homebrew 可用\n'

install_formula() {
    local formula="$1" label="$2"
    if ! confirm "安装或修复 $label"; then
        printf '已退出。\n'; return 1
    fi
    if "$brew_bin" list --versions "$formula" >/dev/null 2>&1; then
        "$brew_bin" reinstall "$formula" || return 1
    else
        "$brew_bin" install "$formula" || return 1
    fi
    hash -r
}

if ! usable git '^git version [0-9]'; then
    printf '❌ Git 未安装或不可用\n'
    if ! install_formula git Git; then
        printf 'Git 安装未完成。\n'; exit 1
    fi
    if ! usable git '^git version [0-9]'; then
        printf '❌ Git 复核未通过，请查看上方安装输出。\n'; exit 1
    fi
fi
printf '✅ Git 可用\n'

# npm is supplied by Node.js; repair the same package if only npm is unavailable.
if ! usable node '^v[0-9]+\.' || ! usable npm '^[0-9]+\.'; then
    printf '❌ Node.js 或 npm 未安装或不可用\n'
    if ! install_formula node 'Node.js（含 npm）'; then
        printf 'Node.js 安装未完成。\n'; exit 1
    fi
    if ! usable node '^v[0-9]+\.' || ! usable npm '^[0-9]+\.'; then
        printf '❌ Node.js/npm 复核未通过，请查看上方安装输出。\n'; exit 1
    fi
fi
printf '✅ Node.js 和 npm 可用\n'
printf '\n✅ 基础环境准备完成，可以继续安装 Agent CLI。\n'
