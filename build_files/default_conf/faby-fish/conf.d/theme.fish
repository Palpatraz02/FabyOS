function fish_prompt
    set -l last_status $status
    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l red (set_color -o red)
    set -l blue (set_color -o blue)
    set -l normal (set_color normal)
    set -l brcyan (set_color -o brcyan)
    set -l brblue (set_color -o brblue)
    set -l brorange (set_color ff8700)

    if set -q CONTAINER_ID
        switch "$CONTAINER_ID"
            case kali
                echo -n -s $brblue " " $normal
            case '*'
                echo -n -s $yellow "[$CONTAINER_ID] " $normal
        end
        end

    echo -s $blue (prompt_pwd) $normal

    if fish_git_prompt > /dev/null
        echo -n -s $brorange "" $cyan (fish_git_prompt) $normal " "
    end

    if set -q VIRTUAL_ENV
        set -l venv_name (basename "$VIRTUAL_ENV")
        echo -n -s $blue " " $normal "($venv_name) "
    end

    if not test $last_status -eq 0
        set_color red
    end

    echo -n "❯ "
    set_color normal
end

function fish_right_prompt
    if test $CMD_DURATION -gt 100
        set -l duration (math --scale=2 "$CMD_DURATION / 1000")
        set_color brblack
        echo -n -s "$duration"s" "
        set_color normal
    end
end

set -g fish_greeting ""

set -g fish_color_autosuggestion 'brblack' '--theme=default'
set -g fish_color_cancel '-r' '--theme=default'
set -g fish_color_command 'normal' '--theme=default'
set -g fish_color_comment 'red' '--theme=default'
set -g fish_color_cwd 'green' '--theme=default'
set -g fish_color_cwd_root 'red' '--theme=default'
set -g fish_color_end 'green' '--theme=default'
set -g fish_color_error 'brred' '--theme=default'
set -g fish_color_escape 'brcyan' '--theme=default'
set -g fish_color_history_current '--bold' '--theme=default'
set -g fish_color_host 'normal' '--theme=default'
set -g fish_color_host_remote 'yellow' '--theme=default'
set -g fish_color_normal 'normal' '--theme=default'
set -g fish_color_operator 'brcyan' '--theme=default'
set -g fish_color_param 'cyan' '--theme=default'
set -g fish_color_quote 'yellow' '--theme=default'
set -g fish_color_redirection 'cyan' '--bold' '--theme=default'
set -g fish_color_search_match 'white' '--background=brblack' '--bold' '--theme=default'
set -g fish_color_selection 'white' '--background=brblack' '--bold' '--theme=default'
set -g fish_color_status 'red' '--theme=default'
set -g fish_color_user 'brgreen' '--theme=default'
set -g fish_color_valid_path '--underline' '--theme=default'


set -g fish_pager_color_progress brwhite --background=cyan
set -g fish_pager_color_prefix white --bold --underline
set -g fish_pager_color_completion normal
set -g fish_pager_color_description 555 yellow

set -g fish_key_bindings fish_vi_key_bindings


if not status is-interactive
    return
end

if type -q fzf
    fzf --fish | source
    set -x FZF_DEFAULT_OPTS ' --color=bg+:-1,bg:-1,spinner:#ff8700,hl:#00ffff --color=fg:-1,header:#00ffff,info:#ff8700,pointer:#00afff --color=marker:#ff8700,fg+:#ffffff,prompt:#00ffff,hl+:#00ffff --height 40% --layout=reverse --border'
end

if type -q zoxide
    zoxide init fish --cmd cd | source
end