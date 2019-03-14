workflow "Checks" {
  on = "push"
  resolves = [
    "Shell-Scripts",
    "JQ",
  ]
}

action "Shell-Scripts" {
  uses = "actions/bin/shellcheck@master"
  args = "**/*.sh"
}

action "JQ" {
  uses = "home-assistant/actions/jq@master"
  args = "**/*.json"
}
