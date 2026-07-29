function yazi --description 'yazi wrapper: 进入切英文输入法,退出恢复原输入法(同 nvim im-select 思路)'
    set -l prev (macism 2>/dev/null)
    type -q macism; and macism com.apple.keylayout.US
    command yazi $argv
    set -l code $status
    test -n "$prev"; and macism "$prev" 2>/dev/null
    return $code
end
