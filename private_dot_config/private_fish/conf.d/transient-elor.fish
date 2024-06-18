function transient_prompt_func --description 'Write out the left prompt'
    set --local color green
    set --local status_text ""
    if test $transient_pipestatus[-1] -ne 0
        set status_text " [$transient_pipestatus]"
        set color red
    end
    set --local suffix '›'
    if functions -q fish_is_root_user; and fish_is_root_user
        set suffix '#'
    end

    echo -en (set_color brblack)"["(date "+%H:%M")"] "(set_color $color)"$status_text$suffix "(set_color normal)
end

function transient_rprompt_func --description 'Write out the right prompt'
    echo -en (set_color brblack)(prompt_pwd)(set_color normal)
end

function transient_elor_fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status red

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix '›'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal
end

# Defined in /opt/homebrew/Cellar/fish/3.7.1/share/fish/functions/fish_prompt.fish @ line 4
function fish_prompt --description 'Write out the prompt'
    transient_elor_fish_prompt
    echo
    transient_prompt_func
end
