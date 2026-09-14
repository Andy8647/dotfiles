# budgetcheck — fish function 包一个 python3 脚本
#
# 安装:
#   1) 把 budgetcheck.py 放到一个稳定位置,比如:
#        mkdir -p ~/.local/share/budgetcheck
#        cp budgetcheck.py ~/.local/share/budgetcheck/
#   2) 把本文件放进 fish function 目录:
#        cp budgetcheck.fish ~/.config/fish/functions/budgetcheck.fish
#      (若你用 chezmoi 管理 dotfiles,记得同步)
#   3) 新开一个 shell,或 `source ~/.config/fish/functions/budgetcheck.fish`
#
# 首次运行会在 ~/.config/budgetcheck/config.json 生成默认配置模板。

function budgetcheck --description '算到目标日期的总开销,判断余额够不够'
    # python3 自检:macOS 不一定预装可用的 python3
    if not command -q python3
        echo "budgetcheck: 找不到 python3。装一个再来:" >&2
        echo "  brew install python3        # 或用 pyenv" >&2
        return 1
    end

    # 定位脚本(优先用户安装位置;本机由 chezmoi 管理)
    set -l script
    for cand in \
        "$HOME/.local/share/budgetcheck/budgetcheck.py" \
        "$HOME/.config/budgetcheck/budgetcheck.py"
        if test -f "$cand"
            set script "$cand"
            break
        end
    end

    if test -z "$script"
        echo "budgetcheck: 找不到 budgetcheck.py,请先安装(见函数文件顶部说明)。" >&2
        return 1
    end

    python3 "$script" $argv
end
