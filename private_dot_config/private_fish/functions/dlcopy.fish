function dlcopy --description 'Copy the newest ~/Downloads file path to the clipboard'
    set -l name (command ls -t ~/Downloads 2>/dev/null | head -n1)
    if test -z "$name"
        echo "~/Downloads is empty"
        return 1
    end
    set -l path ~/Downloads/$name
    printf '%s' "$path" | wl-copy
    echo "copied: $path"
end
