function listen --description "Starts a validated ncat listener in a spawned bash shell."
    # 1. Check if exactly one argument was provided.
    if test (count $argv) -ne 1
        echo "Usage: exlisten <port>" >&2
        return 1
    end

    set --local port $argv[1]

    # 2. Check if the argument is a valid number within the port range.
    if not string match -qr '^\d+$' -- "$port"; or test "$port" -lt 1; or test "$port" -gt 65535
        echo "Error: Port must be a number between 1 and 65535." >&2
        return 1
    end

    # If all checks pass, execute the command.
    expect -c "spawn bash -i; send \"ncat -nlvp $port\\r\"; interact"
end
