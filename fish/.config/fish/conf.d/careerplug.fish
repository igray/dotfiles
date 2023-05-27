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
