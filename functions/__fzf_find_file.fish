function __fzf_find_file -d "List files and folders"
    set -l commandline (__fzf_parse_commandline)
    set -l orig_dir $commandline[1]
    set -l dir $commandline[2]
    set -l fzf_query $commandline[3]

    set -q FZF_FIND_FILE_COMMAND
    or set -l FZF_FIND_FILE_COMMAND "
    command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | sed 's@^\./@@'"

    begin
        eval "$FZF_FIND_FILE_COMMAND | "(__fzfcmd) "-m $FZF_DEFAULT_OPTS $FZF_FIND_FILE_OPTS --query \"$fzf_query\"" | while read -l s; set results $results $s; end
    end

    if test -z "$results"
        commandline -f repaint
        return
    else
        commandline -t ""
    end

    for result in $results
        if test "$dir" = "."
            commandline -it -- (string escape $result)
        else
            commandline -it -- $orig_dir
            if string match -qv -- "/*" $result; and string match -qv -- "*/" $orig_dir
                commandline -it -- '/'
            end
            commandline -it -- (string escape $result)
        end
        commandline -it -- " "
    end
    commandline -f repaint
end
