function chrome-debug --description 'Launch a separate Chrome (debug profile) with remote debugging :9222 for chrome-devtools MCP'
    set -l port 9222
    if set -q argv[1]
        set port $argv[1]
    end
    # 独立调试 profile:已登录 UNSW,且 Chrome 148+ 要求非默认 user-data-dir 才能开调试端口
    set -l profile "$HOME/.chrome-debug-profile"

    # 端口已在监听 → 直接复用,什么都不动
    if curl -s --max-time 1 http://127.0.0.1:$port/json/version >/dev/null 2>&1
        echo "✓ Chrome 调试端口 :$port 已在运行,直接用即可"
        return 0
    end

    # -n 开新实例;独立 profile,不影响日常 Chrome,也不需要退出它
    open -na "Google Chrome" --args --remote-debugging-port=$port --user-data-dir="$profile"

    for i in (seq 1 50)
        if curl -s --max-time 1 http://127.0.0.1:$port/json/version >/dev/null 2>&1
            echo "✓ 调试 Chrome 已就绪 :$port (profile: $profile)"
            return 0
        end
        sleep 0.5
    end
    echo "✗ 启动后 25s 内端口 :$port 仍无响应,检查 Chrome 是否被拦截"
    return 1
end
