# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"
plugins=(git ssh-agent)

# User configuration
source $ZSH/oh-my-zsh.sh

DEFAULT_USER=$(whoami)
export VISUAL=em
export EDITOR=$VISUAL
export GPG_TTY=$(tty)

# get fasd cranking
eval "$(fasd --init auto)"

# don't share history between shells
unsetopt share_history

##########################################################
# Python configuration
##########################################################

function setup_virtualenv() {
  export VIRTUALENVWRAPPER_PYTHON=python3
  export WORKON_HOME=$HOME/.virtualenvs
  export PROJECT_HOME=$HOME/Devel
  source /usr/local/bin/virtualenvwrapper.sh
}

alias cdu="cd $UNIVERSE_HOME"
alias cds="cd $SPARK_HOME"
alias cdd="cd $HOME/dotfiles"
alias tmuxcopy="tmux list-buffers | head -n1 | sed 's/^\([^:]*\).*/\1/' | xargs tmux show-buffer -b | pbcopy"

unalias gcm &> /dev/null
alias gcm='git commit -m'

alias gcan='git commit --amend --no-edit'

unalias gca &> /dev/null
alias gca='git commit --amend'

alias gdc='git diff --cached'

alias gmbm='git merge-base HEAD master'
alias gdm='git diff $(git merge-base HEAD master)'
alias gdr='git diff $(git rev-parse --abbrev-ref --symbolic-full-name @{u})'
alias gdp='git diff HEAD~'
alias gpc='git push -u origin $(git rev-parse --abbrev-ref HEAD)'
alias gpd='git push -u databricks $(git rev-parse --abbrev-ref HEAD)'

gdb () {
  git diff $(git merge-base HEAD $1) $@
}

function gdn() {
  set -x
  git diff --color=always $@ | grep -v "^[^:print:]*-" | less
  set +x
}

function kubecfg() {
  UNIVERSE_DIR=$(git rev-parse --show-toplevel)
  $UNIVERSE_DIR/bazel-bin/deployment/kubecfg/kubecfg $@
}

function update_kube_shard() {
  UNIVERSE_DIR=$(git rev-parse --show-toplevel)
  $UNIVERSE_DIR/bazel-bin/deployment/update/update_kube_shard $@
}

alias k=kubecfg
alias kd='kubecfg --context=dev --namespace=development'
alias kdv='kubecfg --context=dev --namespace=vault'
alias kdcv='kubecfg --context=dev --namespace=central-vault'
alias kdd='kubecfg --context=dev --namespace=default'
alias kda='kubecfg --context=dev --namespace=accounts'
alias ks='kubecfg --context=staging --namespace=staging'
alias ksv='kubecfg --context=staging --namespace=vault'
alias kscv='kubecfg --context=staging --namespace=central-vault'
alias ksd='kubecfg --context=staging --namespace=default'
alias ksa='kubecfg --context=staging --namespace=accounts'
alias kp='kubecfg --context=prod --namespace=production'
alias kpv='kubecfg --context=prod --namespace=vault'
alias kpcv='kubecfg --context=prod --namespace=central-vault'
alias kpd='kubecfg --context=prod --namespace=default'
alias kpa='kubecfg --context=prod --namespace=accounts'
alias kdaw='kubecfg --context=dev-azure-westus --namespace=development'
alias kdawa='kubecfg --context=dev-azure-westus --namespace=accounts'
alias kdae='kubecfg --context=dev-azure-eastus --namespace=development'
alias kdaea='kubecfg --context=dev-azure-eastus --namespace=accounts'
alias kdaa='kubecfg --context=dev-azure-amsterdam --namespace=develompent'
alias kdaaa='kubecfg --context=dev-azure-amsterdam --namespace=accounts'
alias ksaw='kubecfg --context=staging-azure-westus --namespace=development'
alias ksawa='kubecfg --context=staging-azure-westus --namespace=accounts'
alias ksae='kubecfg --context=staging-azure-eastus --namespace=development'
alias ksaea='kubecfg --context=staging-azure-eastus --namespace=accounts'
alias ksaa='kubecfg --context=staging-azure-amsterdam --namespace=develompent'
alias ksaaa='kubecfg --context=staging-azure-amsterdam --namespace=accounts'
alias em='emacsclient -t --alternate-editor ""'

if [[ -e ~/.zshrc_local ]]; then
  source ~/.zshrc_local
fi
stty -ixon

alias sshjenkins='ssh -i ~miles/.ssh/jenkins-key.pem'
alias sap='source activate python2711'
alias watch='watch '
bashcmd() {
    echo 'env COLUMNS=`tput cols` LINES=`tput lines` TERM=xterm bash'
}

showtests () {
    bazel build //test:unit_tests
    UNIVERSE_DIR=$(git rev-parse --show-toplevel)
    TEST_RUNNER="$UNIVERSE_DIR/bazel-bin/test/unit_tests"
    $TEST_RUNNER -t $(git merge-base upstream/master HEAD) --list-suites --no-shutdown-bazel | sort
}

pushcfn () {
    UNIVERSE_DIR=$(git rev-parse --show-toplevel)
    PUSH_CFN="$UNIVERSE_DIR/bazel-bin/sre/tools/cloudformation/push_cloudformation"
    if [[ ! -f "$PUSH_CFN" ]]; then
        echo Building push_cloudformation
        bazel build //sre/tools/cloudformation:push_cloudformation
    fi
    $PUSH_CFN $@
}

setup_ensime () {
    UNIVERSE_DIR=$(git rev-parse --show-toplevel)
    $UNIVERSE_DIR/ensime/create_ensime.py -t //central:central-client //central:server //manager:manager //common:common //extern:extern //chauffeur-api:chauffeur-api //billing:billing //testing:testing //central:server_test //central:central-client_test //vault:vault //api:api //central/api:api_proto //webapp:webapp //webapp:webapp_test
}

setup_project () {
    if [[ $1 == "billing" ]]; then
        ./eng-tools/create_project.py -t //central/api:api_proto //api:proto //vault:vault -n universe-billing -s central common extern api billing acl/client/ secrets/ testing common-web -u
    elif [[ $1 == "elastic-spark" ]]; then
        ./eng-tools/create_project.py -t //elastic-spark-common:elastic-spark-common //central/api:api_proto //api:proto //acl/client:client //secrets:secrets //maven/jetty9-hadoop1/org.quartz-scheduler/quartz:quartz -n universe-elastic-spark -s elastic-spark common extern api elastic-spark-common acl/client/ secrets/ testing common-web -u
    else
        echo "$1 must be one of billing, elastic-spark"
        exit 1
    fi
}

# Twig completion
autoload -U bashcompinit
bashcompinit
source ~/.twig/twig-completion.bash
