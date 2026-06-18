function cz-sync --description "Smart sync for Chezmoi: updates existing files and auto-discovers new GUI configs"
    echo "🚀 Step 1: Refreshing modifications to existing tracked files..."
    chezmoi re-add

    echo "🔍 Step 2: Scanning managed directories for newly created files..."

    # 1. Get all absolute paths managed by Chezmoi
    # 2. Extract their active parent directories
    # 3. Explicitly bypass the root $HOME directory to prevent pulling in untracked home junk
    set tracked_dirs (chezmoi managed --path-style=absolute | while read -l path
        if test -d "$path"
            if test "$path" != "$HOME"
                echo "$path"
            end
        else if test -f "$path"
            set parent_dir (dirname "$path")
            if test "$parent_dir" != "$HOME"
                echo "$parent_dir"
            end
        end
    end | sort -u)

    # Run 'chezmoi add' exclusively on the isolated configuration folders
    for dir in $tracked_dirs
        if test -d "$dir"
            chezmoi add "$dir"
        end
    end

    echo "📦 Step 3: Staging updates and pushing safely to GitHub..."
    chezmoi git add .

    # Create a clean, readable timestamp for the Git commit
    set current_time (date "+%Y-%m-%d %H:%M:%S")
    chezmoi git commit -m "Auto-sync dotfiles ($current_time)"
    chezmoi git push

    echo "✅ Sync complete! Your configurations are perfectly up to date."
end
