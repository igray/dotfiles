# Completions for CareerPlug's bin/ssh/connect_to (ats repo).
#
# connect_to parses its flags with getopts "c:n:p:grstx" and then takes up to
# two positional arguments: <environment> [role]. Flags therefore normally come
# *before* the positionals, which is why the conditions below stay permissive
# while the environment is still unknown and only narrow once it has been typed.

function __connect_to_positionals --description 'Positional args given to connect_to so far'
    set -l tokens (commandline --cut-at-cursor --tokens-expanded)
    set -l want_arg 0

    for token in $tokens[2..]
        if test $want_arg -eq 1
            set want_arg 0
            continue
        end

        if string match -q -- '-*' $token
            # Of the accepted flags only c, n and p take an argument. In a
            # cluster such as -rn the argument belongs to the trailing flag, so
            # the next token is only consumed when the arg-taking flag ends the
            # cluster (-n 17); otherwise the value is attached (-n17).
            set -l flags (string split '' -- (string sub --start 2 -- $token))
            for i in (seq (count $flags))
                if contains -- $flags[$i] c n p
                    test $i -eq (count $flags); and set want_arg 1
                    break
                end
            end
        else
            echo $token
        end
    end
end

function __connect_to_needs_environment --description 'True before the environment has been typed'
    set -l positionals (__connect_to_positionals)
    test (count $positionals) -eq 0
end

function __connect_to_needs_role --description 'True when a role is the next expected argument'
    set -l positionals (__connect_to_positionals)
    test (count $positionals) -eq 1
    # bastion and job-scorer are single-server environments and take no role.
    and not contains -- $positionals[1] bastion job-scorer
end

function __connect_to_environment_is --description 'True when the typed environment is one of $argv'
    set -l positionals (__connect_to_positionals)
    test (count $positionals) -ge 1
    and contains -- $positionals[1] $argv
end

function __connect_to_environment_may_be --description 'Like __connect_to_environment_is, but also true while unknown'
    __connect_to_needs_environment; or __connect_to_environment_is $argv
end

function __connect_to_instance_numbers --description 'Candidate values for -n'
    set -l positionals (__connect_to_positionals)
    set -l environment ''
    set -l role ''
    test (count $positionals) -ge 1; and set environment $positionals[1]
    test (count $positionals) -ge 2; and set role $positionals[2]

    # dev-staging numbers are per-developer, so CPSTAGING_NUM is the only value
    # knowable without hitting AWS.
    if test -n "$CPSTAGING_NUM"; and contains -- "$environment" dev-staging ''
        printf '%s\tCPSTAGING_NUM\n' $CPSTAGING_NUM
    end

    # Ranges as documented in connect_to's own usage text.
    if contains -- "$environment" production ''
        if test "$role" = worker
            printf '%s\tproduction worker\n' (seq 1 2)
        else
            printf '%s\tproduction web\n' (seq 1 18)
        end
    end
end

# connect_to never takes a bare file argument.
complete -c connect_to -f

# Environments
complete -c connect_to -n __connect_to_needs_environment -a bastion -d 'Bastion host'
complete -c connect_to -n __connect_to_needs_environment -a job-scorer -d 'ml.job.scorer'
complete -c connect_to -n __connect_to_needs_environment -a production -d 'Production (requires a role)'
complete -c connect_to -n __connect_to_needs_environment -a staging -d 'Staging (requires a role)'
complete -c connect_to -n __connect_to_needs_environment -a dev-staging -d 'Dev staging (requires a role and -n/CPSTAGING_NUM)'

# Roles, narrowed to the ones the chosen environment actually maps to a server
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is production' -a web -d EC2ContainerService-production-ats-web
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is production' -a worker -d EC2ContainerService-production-ats-worker
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is production' -a escalation -d 'ats.production.escalations'
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is production' -a onb -d onb-production-classic-al2023
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is production' -a onb-docs -d onb-production-classic-docs-clone

complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is staging' -a web -d EC2ContainerService-staging-ats-web
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is staging' -a worker -d EC2ContainerService-staging-ats-worker
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is staging' -a onb -d onb-staging-classic

complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is dev-staging' -a web -d 'ats-staging-$n'
complete -c connect_to -n '__connect_to_needs_role; and __connect_to_environment_is dev-staging' -a worker -d 'ats-staging-$n-worker'

# Global options
complete -c connect_to -s c -r -F -d 'Copy a local file up to the server'
complete -c connect_to -s p -x -d 'Pull a remote file down from the server'
complete -c connect_to -s n -x -a '(__connect_to_instance_numbers)' -d 'Pre-select the instance number'
complete -c connect_to -s r -d 'Start the Rails console on connect'
complete -c connect_to -s s -d 'Start a shell on connect'
complete -c connect_to -s x -d 'Skip ssh; print manual connect instructions (60s key window)'

# Environment-specific options
complete -c connect_to -s g -n '__connect_to_environment_may_be bastion' -d 'bastion: retrieve gauth 2FA code for devteam@careerplug.com'
complete -c connect_to -s t -n '__connect_to_environment_may_be dev-staging' -d 'dev-staging: execute dev tunnel'
