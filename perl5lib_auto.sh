# -----------------------------------------------------------------------------
# perl5lib_auto.sh — Automatically set PERL5LIB when cd'ing into a project
#
# Drop-in script for use in Bash.
#
# ✅ Features:
# - Recursively scans for `lib/` directories containing `.pm` files
# - Excludes known build/IDE dirs and versioned-release folders
# - Skips scanning when in specified root directories (e.g., ~/git)
# - Caps the number of lib dirs included to avoid over-inclusion
# - Supports verbose/debug output and dry-run testing
# - All behaviour configurable via environment variables
#
# 🔄 Usage:
# 1. Save this file (e.g., at ~/bin/perl5lib_auto.sh)
# 2. In your ~/.bashrc (or ~/.bash_profile), add:
#
#     source ~/bin/perl5lib_auto.sh
#
# 3. Open a new terminal or run `source ~/.bashrc`
#
# 🌍 Environment Variables:
# PERL5LIB_LIB_CAP          Max allowed lib dirs (default: 3)
# PERL5LIB_FORCE            Set to 1 to override exclusions and cap
# PERL5LIB_APPEND           Set to 1 to append to existing PERL5LIB
# PERL5LIB_VERBOSE          Set to 1 for debug output
# PERL5LIB_DRYRUN           Set to 1 to preview changes without applying
# PERL5LIB_EXCLUDE_DIRS     Colon-separated absolute paths to skip entirely
# PERL5LIB_EXCLUDE_PATTERNS Colon-separated substrings to filter out of paths
# -----------------------------------------------------------------------------

cd() {
  builtin cd "$@" || return

  local current_dir
  current_dir=$(realpath .)

  local cap="${PERL5LIB_LIB_CAP:-3}"
  local exclude_dirs="${PERL5LIB_EXCLUDE_DIRS:-$HOME/git}"
  local exclude_patterns="${PERL5LIB_EXCLUDE_PATTERNS:-.vscode:blib}"

  # Skip explicitly excluded root dirs (exact match only)
  IFS=: read -ra _exclude_dir_array <<< "$exclude_dirs"
  for excl in "${_exclude_dir_array[@]}"; do
    if [[ "$current_dir" == "$excl" ]]; then
      if [ -z "$PERL5LIB_FORCE" ]; then
        [ "$PERL5LIB_VERBOSE" = "1" ] && echo "[PERL5LIB] Skipping excluded dir: $current_dir (matches $excl)"
        return
      else
        [ "$PERL5LIB_VERBOSE" = "1" ] && echo "[PERL5LIB] FORCE override for excluded dir: $current_dir (matches $excl)"
      fi
    fi
  done

  unset PERL5LIB_NEW
  local libs=()

  IFS=$'\n' read -d '' -r -a libs < <(
    find . -type d -name lib \
      -exec bash -c '
        exclude_patterns="$1"; shift
        IFS=: read -ra patterns <<< "$exclude_patterns"
        for dir in "$@"; do
          skip=0
          for pat in "${patterns[@]}"; do
            [[ "$dir" == *"$pat"* ]] && skip=1 && break
          done
          [[ "$dir" =~ /[A-Za-z0-9_.-]+-[0-9]+\.[0-9]+(\.[0-9]+)?/ ]] && skip=1
          if [ "$skip" -eq 0 ] && find "$dir" -type f -name "*.pm" | grep -q .; then
            realpath "$dir"
          fi
        done
      ' bash "$exclude_patterns" {} + && printf '\0'
  )

  if [ "$PERL5LIB_VERBOSE" = "1" ]; then
    echo "[PERL5LIB] Found ${#libs[@]} eligible lib dir(s):"
    for l in "${libs[@]}"; do echo "  $l"; done
  fi

  if [ "${#libs[@]}" -gt "$cap" ] && [ -z "$PERL5LIB_FORCE" ]; then
    [ "$PERL5LIB_VERBOSE" = "1" ] && echo "[PERL5LIB] Too many lib dirs (${#libs[@]} > $cap) — skipping"
    return
  fi

  if [ "${#libs[@]}" -gt 0 ]; then
    PERL5LIB_NEW=$(IFS=:; echo "${libs[*]}")

    if [ "$PERL5LIB_DRYRUN" = "1" ]; then
      echo "[PERL5LIB] DRYRUN: would set PERL5LIB to:"
      if [ -n "$PERL5LIB_APPEND" ] && [ -n "$PERL5LIB" ]; then
        echo "$PERL5LIB:$PERL5LIB_NEW"
      else
        echo "$PERL5LIB_NEW"
      fi
      return
    fi

    if [ -n "$PERL5LIB_APPEND" ] && [ -n "$PERL5LIB" ]; then
      export PERL5LIB="$PERL5LIB:$PERL5LIB_NEW"
    else
      export PERL5LIB="$PERL5LIB_NEW"
    fi

    echo "PERL5LIB set to: $PERL5LIB"
  elif [ "$PERL5LIB_VERBOSE" = "1" ]; then
    echo "[PERL5LIB] No matching lib dirs found"
  fi
}

