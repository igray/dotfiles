function cpBranch
  currentGitBranch | cut -d '-' -f-2
end

function cpcommit -a message
  set branch (cpBranch)
  gcm "$branch $message"
end

function cpassets
  set branch (cpBranch)
  gcm "$branch Built Assets [assets only]"
end

function cppr
  gh pr create --head igray:(currentGitBranch)
end

function gpu
  git pull origin (currentGitBranch)
end

function gpf
  git push --force-with-lease
end

function ciboost
  set branch (currentGitBranch)
  if test "$branch" = "main"
    echo "You are on main branch, please checkout to a feature branch"
    return 1
  end
  gco main
  gpu
  gco "$branch"
  git rebase main
  git show -s --format=%B | sed '1 s/\( \[ciboost\]\)\?$/ [ciboost]/' | git commit --amend -F -
  gpf
end
