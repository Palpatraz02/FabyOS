function cz-sync --description "Smart sync for Chezmoi: updates existing files and auto-discovers new GUI configs"
    echo "🚀 Step 1: Refreshing modifications to existing tracked files..."
    chezmoi re-add

    echo "🔍 Step 2: Scanning managed directories for truly untracked files..."

    # Define "dumping ground" directories that should NEVER trigger auto-discovery.
    # You can add more to this list later if other folders get annoying.
    set ignored_parents "$HOME" "$HOME/.config" "$HOME/.local/share"

    # 1. Get all absolute paths managed by Chezmoi
    # 2. Extract their active parent directories
    # 3. Explicitly bypass the ignored parents defined above
    set tracked_dirs (chezmoi managed --path-style=absolute | while read -l path
        if test -d "$path"
            if not contains "$path" $ignored_parents
                echo "$path"
            end
        else if test -f "$path"
            set parent_dir (dirname "$path")
            if not contains "$parent_dir" $ignored_parents
                echo "$parent_dir"
            end
        end
    end | sort -u)

    # 4. Get all unmanaged paths, and only add them if they live inside a tracked directory.
    chezmoi unmanaged --path-style=absolute | while read -l unmanaged_path
        for dir in $tracked_dirs
            if string match -q "$dir/*" "$unmanaged_path"
                echo "➕ Auto-discovered new item: $unmanaged_path"
                chezmoi add "$unmanaged_path"
                break # Move to the next unmanaged item once matched
            end
        end
    end

    echo "📦 Step 3: Staging updates and pushing safely to GitHub..."
    chezmoi git -- add .

    set current_time (date "+%Y-%m-%d %H:%M:%S")
    chezmoi git -- commit -m "Auto-sync dotfiles ($current_time)"
    chezmoi git -- push

    echo "✅ Sync complete! Your configurations are perfectly up to date."
end
