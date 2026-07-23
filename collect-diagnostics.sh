#!/usr/bin/env bash
set -u

report="codex-safe-report.txt"
tmp_report="${report}.tmp"

cleanup() {
  rm -f "$tmp_report"
}
trap cleanup EXIT

safe_version() {
  label="$1"
  command_name="$2"
  shift 2
  if command -v "$command_name" >/dev/null 2>&1; then
    raw_value=$("$command_name" "$@" 2>&1 || true)
    if [ "$command_name" = "codex" ]; then
      value=$(printf '%s\n' "$raw_value" | sed -n -E '/^codex-cli[[:space:]]+[0-9]+([.][0-9]+)*/p' | tail -n 1)
      value=${value:-version unreadable}
    else
      value=$(printf '%s\n' "$raw_value" | head -n 1 | tr '\r\n' ' ')
    fi
    value=$(printf '%s' "$value" | sed -E \
      -e 's#(/Users|/home)/[^ /]+#<USER_HOME>#g' \
      -e 's#[A-Za-z]:\\[^[:space:]]+#<PATH>#g' \
      -e 's#(^|[[:space:]"])/[A-Za-z0-9._~!$&()*+,;=:@%/?-]+#\1<PATH>#g' \
      -e 's#sk-[A-Za-z0-9_-]+#<REDACTED>#g' \
      -e 's#[A-Za-z0-9_-]{48,}#<LONG_VALUE_REDACTED>#g')
    printf '%s: installed | %s\n' "$label" "$value"
  else
    printf '%s: not found\n' "$label"
  fi
}

presence() {
  label="$1"
  shift
  found="no"
  for name in "$@"; do
    eval 'value=${'"$name"'-}'
    if [ -n "$value" ]; then
      found="yes"
      break
    fi
  done
  printf '%s: %s\n' "$label" "$found"
}

http_probe() {
  label="$1"
  url="$2"
  if ! command -v curl >/dev/null 2>&1; then
    printf '%s: not tested (curl not found)\n' "$label"
    return
  fi
  code=$(curl -L -sS -o /dev/null --connect-timeout 5 --max-time 10 \
    -w '%{http_code}' "$url" 2>/dev/null || true)
  case "$code" in
    2??|3??|401|403|404) printf '%s: reachable (HTTP %s)\n' "$label" "$code" ;;
    000|'') printf '%s: unreachable or timed out\n' "$label" ;;
    *) printf '%s: responded (HTTP %s)\n' "$label" "$code" ;;
  esac
}

{
  printf 'Codex Safe Diagnostic Report v1.0\n'
  printf 'Generated: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'Collector: read-only; no secret values or file contents collected\n\n'

  printf '[System]\n'
  printf 'OS family: %s\n' "$(uname -s 2>/dev/null || printf 'unknown')"
  printf 'Architecture: %s\n' "$(uname -m 2>/dev/null || printf 'unknown')"
  if [ -r /etc/os-release ]; then
    os_name=$(sed -n 's/^NAME="\{0,1\}\([^"[:cntrl:]]*\)"\{0,1\}$/\1/p' /etc/os-release | head -n 1)
    printf 'Distribution: %s\n' "${os_name:-unknown}"
  fi
  printf 'Shell family: %s\n\n' "$(basename "${SHELL:-unknown}")"

  printf '[Tools]\n'
  safe_version 'Codex CLI' codex --version
  safe_version 'Node.js' node --version
  safe_version 'npm' npm --version
  safe_version 'Git' git --version
  safe_version 'curl' curl --version
  safe_version 'Python' python3 --version
  printf '\n[Configuration presence]\n'
  presence 'Proxy configured' HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
  presence 'Custom CA configured' CODEX_CA_CERTIFICATE SSL_CERT_FILE NODE_EXTRA_CA_CERTS
  presence 'Codex home override configured' CODEX_HOME

  printf '\n[Official endpoint reachability]\n'
  http_probe 'Codex installer host' 'https://chatgpt.com/codex/install.sh'
  http_probe 'OpenAI API host' 'https://api.openai.com/'

  printf '\n[Codex self-check availability]\n'
  if command -v codex >/dev/null 2>&1 && codex doctor --help >/dev/null 2>&1; then
    printf 'codex doctor: available\n'
  elif command -v codex >/dev/null 2>&1; then
    printf 'codex doctor: unavailable in this Codex version\n'
  else
    printf 'codex doctor: not tested (Codex CLI not found)\n'
  fi

  printf '\n[Customer symptom]\n'
  printf 'Please add one redacted error line here before sending: \n'
} > "$tmp_report"

mv "$tmp_report" "$report"
trap - EXIT
printf 'Report created: %s\n' "$report"
printf 'Open it and complete the manual privacy check before sending.\n'
