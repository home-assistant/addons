workflow "Checks" {
  on = "push"
  resolves = [
    "Shell-Scripts",
    "home-assistant/actions/jq@master",
  ]
}

action "Shell-Scripts" {
  uses = "actions/bin/shellcheck@master"
  args = "**/*.sh"
}

action "home-assistant/actions/jq@master" {
  uses = "home-assistant/actions/jq@master"
  args = "**/*.json"
}
