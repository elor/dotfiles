function cop # github copilot
  set TMPFILE (mktemp);
  trap "rm -f $TMPFILE" EXIT;

  if /opt/homebrew/bin/github-copilot-cli what-the-shell "$argv" --shellout $TMPFILE
    source $TMPFILE
  else
    return 1
  end
end
