function getdl --description 'Run getbook --file on the newest ~/Downloads file'
    set -l name (command ls -t ~/Downloads 2>/dev/null | head -n1)
    if test -z "$name"
        echo "~/Downloads is empty"
        return 1
    end
    set -l path ~/Downloads/$name
    echo "→ getbook --file $path"
    getbook --file $path $argv
end
