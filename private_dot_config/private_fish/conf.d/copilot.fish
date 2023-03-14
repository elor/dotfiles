function copilot_what-the-shell
  set TMPFILE (mktemp);
  trap "rm -f $TMPFILE" EXIT;

  if /opt/homebrew/bin/github-copilot-cli what-the-shell "$argv" --shellout $TMPFILE
    if [ -e "$TMPFILE" ]
      let FIXED_CMD "$(cat $TMPFILE)";
      
      eval "$FIXED_CMD"
    else
      echo "Apologies! Extracting command failed"
    end
  else
    return 1
  end
end

alias 'copilot' 'copilot_what-the-shell';
alias 'cop' 'copilot';