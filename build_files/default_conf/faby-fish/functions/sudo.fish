if set -q CONTAINER_ID
    function sudo
        switch "$argv[1]"
            case host
                set -e argv[1]
                distrobox-host-exec -- sudo $argv
            case docker
                distrobox-host-exec -- sudo $argv
            case '*'
                command sudo $argv
        end
    end
end