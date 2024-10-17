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

# Convert shellcheck "gcc" format to GitHub Actions annotations.
# https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-error-message
annotate_shellcheck() {
    local file lineno _ severity message
    while IFS=: read -r file lineno _ severity message; do
        case "${severity# }" in
        error ) severity="error" ;;
        warning ) severity="warning" ;;
        info | note | style ) severity="notice" ;;
        esac
        printf "::%s file=%s,line=%d::%s\n" "$severity" "$file" "$lineno" "${message# }"
    done
}

if [ "${1-}" = "-l" ]; then
    # Print only the list of files where shellcheck has detected violations.
    shellcheck --format=gcc "${scan_files[@]}" | cut -d: -f1 | sort -u
elif [ -z "$GITHUB_ACTIONS" ]; then
    shellcheck "${scan_files[@]}"
else
    shellcheck --version
    echo
    set -o pipefail
    shellcheck --format=gcc "${scan_files[@]}" | annotate_shellcheck
fi