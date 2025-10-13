#!/usr/bin/env zsh

# Environment variables
export LANG='en_US.UTF-8'
export XKB_DEFAULT_LAYOUT="eu"
export XKB_DEFAULT_OPTIONS="caps:ctrl_modifier"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export QT_QPA_PLATFORMTHEME=qt5ct
export DOTFILES="$HOME/.dotfiles"
export LESS="-R"
export PAGER="less -R"
export MANPAGER="less -R --use-color -Dd+g -Du+y -Ds+r"
export SBCL_HOME="/usr/lib/sbcl/"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

## Fix an issue with gpg signing
export GPG_TTY=$(tty)

# Perl
PERLDIR="$HOME/.local/perl5"
PERL5LIB="$PERLDIR/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL5LIB
PERL_LOCAL_LIB_ROOT="$PERLDIR${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_LOCAL_LIB_ROOT
PERL_MB_OPT="--install_base \"$PERLDIR\""
export PERL_MB_OPT
PERL_MM_OPT="INSTALL_BASE=$PERLDIR"
export PERL_MM_OPT

# PATH
typeset -gU cdpath fpath mailpath path

## MacOS is stupid so we need to make sure brew is in the path here again,
## even though it's already done that in .profile
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

for p (
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "$HOME/.roswell/bin"
        "$PERLDIR/bin"
        "/Library/TeX/texbin"
    ); do
    if [ -d "$p" ]; then
        path+=("$p")
    fi
done
