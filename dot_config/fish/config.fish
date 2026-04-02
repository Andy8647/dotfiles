# Disable greeting
set -g fish_greeting

# Homebrew
eval (/opt/homebrew/bin/brew shellenv)

# ---- Java ----
set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
fish_add_path $JAVA_HOME/bin

# ---- Editor ----
set -gx EDITOR nvim

# ---- iCloud Drive ----
set -gx icd "$HOME/Library/Mobile Documents/com~apple~CloudDocs"

# ---- Perl local::lib ----
set -gx PERL5LIB "$HOME/perl5/lib/perl5"
set -gx PERL_LOCAL_LIB_ROOT "$HOME/perl5"
set -gx PERL_MB_OPT "--install_base \"$HOME/perl5\""
set -gx PERL_MM_OPT "INSTALL_BASE=$HOME/perl5"
fish_add_path $HOME/perl5/bin

# ---- Python (pyenv) ----
status is-interactive; and pyenv init - fish | source

# ---- Antigravity ----
fish_add_path /Users/andy/.antigravity/antigravity/bin

# ---- OpenClaw Completion ----
source /Users/andy/.openclaw/completions/openclaw.fish

# ---- Bun ----
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# ---- Ripgrep ----
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/config

# ---- fzf ----
set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --exclude .git"
fzf --fish | source

# ---- Aliases ----
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first --git"
alias la="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --icons --level=2"
alias cat="bat"

# ---- Abbreviations ----
abbr -a lg lazygit
abbr -a v nvim
abbr -a g git
abbr -a gs "git status -sb"
abbr -a gp "git push"
abbr -a gl "git pull"
abbr -a gd "git diff"
abbr -a gc "git commit"
abbr -a y yazi

# ---- zoxide (smart cd) ----
zoxide init fish | source

# ---- Starship prompt ----
starship init fish | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
