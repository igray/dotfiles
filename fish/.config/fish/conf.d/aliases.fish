# ruby
alias rbb='bundle'
alias rbbe='bundle exec'
alias rbbl='bundle list'
alias rbbo='bundle open'
alias rbbu='bundle update'

# rails
alias ror='bundle exec rails'
alias rorc='bundle exec rails console'
alias rordc='bundle exec rails dbconsole'
alias rordm='bundle exec rake db:migrate'
alias rordM='bundle exec rake db:migrate db:test:clone'
alias rordr='bundle exec rake db:rollback'
alias rorg='bundle exec rails generate'
alias rorlc='bundle exec rake log:clear'
alias rorp='bundle exec rails plugin'
alias rorr='bundle exec rails runner'
alias rors='bundle exec rails server'
alias rorsd='bundle exec rails server --debugger'

# git
function currentGitBranch
  git branch | grep '\*' | awk -e '{ print $2 }'
end

alias gcm='git commit --message'
alias gco='git checkout'
alias gpush='git push'
alias gb='git branch'
function gsb
  command git branch $argv
  command git checkout $argv
end

# other
alias doh='commandline -i "sudo $history[1]";history delete --exact --case-sensitive doh'
alias l='eza'
alias vim='nvim'
