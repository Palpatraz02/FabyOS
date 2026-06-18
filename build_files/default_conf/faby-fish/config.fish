source ~/.config/fish/conf.d/theme.fish
source ~/.config/fish/conf.d/generic_aliases.fish

if not set -q CONTAINER_ID

    alias update='sudo pacman -Syu'
    alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
    alias purge='sudo pacman -Rnsu'
    alias paru='paru --skipreview'
    alias yay='paru'

    alias kali='distrobox enter --root kali'
    alias arch='distrobox enter arch'
    
   
else
    alias sysshell='distrobox-host-exec env SYSTEM_SHELL_MODE=1 fish'
    alias host='distrobox-host-exec -- '
    alias openvpn='host sudo openvpn'
    alias docker='host sudo docker'

    if test "$CONTAINER_ID" = "kali"
        alias update='sudo apt update && sudo apt upgrade -y'
        alias install='sudo apt install'
        alias cleanup='sudo apt autoremove -y'
    end
end

set fzf_preview_dir_cmd eza --all --color=always

# Created by `pipx` on 2026-05-07 15:09:52
set PATH $PATH /home/faby02/.local/bin


# Added by Antigravity CLI installer
set -gx PATH "/home/faby02/.local/bin" $PATH
