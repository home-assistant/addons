#!/usr/bin/env bash
set -eu

declare -a scan_files

# Scan any "*.sh" and "*.bash" files.
while IFS= read -r -d '' file; do
    scan_files+=("$file")
done < <(find . -type f \( -name '*.sh' -o -name '*.bash' \) -print0)

perm_executable="/111"
# BSD `find` on macOS does not support the slash syntax for permissions.
[ "$(uname -s)" = "Darwin" ] && perm_executable="+111"

# Scan any executable files that start with a shebang.
while IFS= read -r -d '' file; do
    [ "$(head -c2 "$file")" = '#!' ] || continue
    scan_files+=("$file")
done < <(find . -type f ! -name '*.*' -perm "$perm_executable" -print0)

if [ "${1-}" = "-l" ]; then
    # Print only the list of files where shellcheck has detected violations.
    shellcheck --format=gcc "${scan_files[@]}" | cut -d: -f1 | sort -u
elif [ -z "$GITHUB_ACTIONS" ]; then
    shellcheck "${scan_files[@]}"
else
    shellcheck --version
    echo
    # If shellcheck fails, ensure that this script fails even after piping to jq.
    set -o pipefail

    # Convert shellcheck JSON format to GitHub Actions annotations:
    # - shellcheck "style" becomes ::notice::
    # - shellcheck "info" becomes ::notice::
    # - shellcheck "note" becomes ::notice::
    # - shellcheck "error" becomes ::error::
    # - shellcheck "warning" becomes ::warning::
    #
    # https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-error-message
    shellcheck --format=json "${scan_files[@]}" | jq -r '
        def workflow_command: if . == "note" or . == "info" or . == "style" then "notice" else . end;
        .[] | "::\(.level | workflow_command) file=\(.file),line=\(.line),endLine=\(.endLine)::\(.message) [SC\(.code)]"
    '
fi