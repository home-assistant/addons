workflow "Checks" {
  on = "push"
  resolves = ["Shell-Scripts"]
}

action "Shell-Scripts" {
  uses = "actions/bin/shellcheck@master"
  args = "**/*.sh"
}
