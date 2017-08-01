export HISTSIZE=2147483647
# Credentials for email sending in billing
export DOCKER_WEBAPP_ALWAYS_RANDOMIZE_PORT=true

if [[ -e ~/.zshenv_local ]]; then
  source ~/.zshenv_local
fi
