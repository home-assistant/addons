#!/usr/bin/env bash
export PS1="\[\e[0;32m\][\h \W]\$ \[\e[m\]"
export SUPERVISOR_TOKEN={{ .supervisor_token }}

ha banner
# shellcheck disable=SC1090
source <(ha completion bash)
