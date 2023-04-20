function !! # github copilot
  set TMPFILE (mktemp)
  trap "rm -f $TMPFILE" EXIT

  if /opt/homebrew/bin/github-copilot-cli what-the-shell "$argv" --shellout $TMPFILE
    echo "- cmd: $(cat $TMPFILE)" >> "$__fish_user_data_dir/fish_history"
    echo "  when: $(date +%s)" >> "$__fish_user_data_dir/fish_history"
    history merge
    bash $TMPFILE
  else
    return 1
  end
end
