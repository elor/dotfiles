  set TMPFILE (mktemp);
  trap "rm -f $TMPFILE" EXIT;
function !! # github copilot

  if /opt/homebrew/bin/github-copilot-cli what-the-shell "$argv" --shellout $TMPFILE
    bash $TMPFILE
  else
    return 1
  end
end
