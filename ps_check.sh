#!/usr/bin/env bash
# test_rand.sh — Random unique int tests for push_swap with checker_linux and colors
# Usage:
#   chmod +x test_rand.sh
#   ./test_rand.sh <numbers_per_test> <number_of_tests>
# Example:
#   ./test_rand.sh 100 10

set -u

if (( $# != 2 )); then
  echo "Usage: $0 <numbers_per_test> <number_of_tests>" >&2
  exit 1
fi

NUM_COUNT=$1
TEST_COUNT=$2

# validate args
case $NUM_COUNT in (*[!0-9]*|'') echo "numbers_per_test must be a positive integer" >&2; exit 1;; esac
case $TEST_COUNT in (*[!0-9]*|'') echo "number_of_tests must be a positive integer" >&2; exit 1;; esac
if (( NUM_COUNT < 1 || TEST_COUNT < 1 )); then
  echo "Both arguments must be >= 1" >&2
  exit 1
fi

# check executables
[[ -x ./push_swap ]] || { echo "Missing ./push_swap" >&2; exit 1; }
[[ -x ./checker_linux ]] || { echo "Missing ./checker_linux" >&2; exit 1; }

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
RESET="\033[0m"

INT_MIN=-2147483648
INT_MAX=2147483647

rand_i32() {
  local u
  u=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
  if (( u >= 2147483648 )); then
    printf '%d\n' $(( u - 4294967296 ))
  else
    printf '%d\n' "$u"
  fi
}

gen_unique_args() {
  local need=$1
  declare -A seen=()
  local -a out=()
  local x
  while (( ${#out[@]} < need )); do
    x=$(rand_i32)
    if [[ -z ${seen[$x]+_} ]]; then
      seen[$x]=1
      out+=("$x")
    fi
  done
  printf '%s\n' "${out[@]}"
}

count_lines() { awk 'END{print NR}'; }
join() { local IFS=' '; echo "$*"; }

printf "%6s | %-3s | %s\n" "Moves" "CHK" "Numbers"
printf -- "-------------------------------------------------------------\n"

TOTAL=0 COUNT=0
MIN=9223372036854775807
MAX=-1
MIN_ARR=() MAX_ARR=()

for (( t=1; t<=TEST_COUNT; t++ )); do
  mapfile -t ARGS < <(gen_unique_args "$NUM_COUNT")

  OUT=$(./push_swap "${ARGS[@]}" 2>/dev/null || true)
  [[ -n $OUT && ${OUT: -1} != $'\n' ]] && OUT+=$'\n'
  MOVES=$(printf %s "$OUT" | count_lines)

  CHK_RAW=$(printf %s "$OUT" | ./checker_linux "${ARGS[@]}" 2>&1 || true)
  CHK_WORD=$(printf '%s' "$CHK_RAW" | tr -d '\r' | awk 'NR==1{print $1}')

  case "$CHK_WORD" in
    OK)   CHK_COLOR="${GREEN}OK${RESET}" ;;
    KO)   CHK_COLOR="${RED}KO${RESET}" ;;
    *)    CHK_COLOR="${RED}ERR${RESET}" ;;
  esac

  printf "%6d | %-7b | %s\n" "$MOVES" "$CHK_COLOR" "$(join "${ARGS[@]}")"

  ((TOTAL += MOVES))
  ((COUNT++))
  if (( MOVES < MIN )); then MIN=$MOVES; MIN_ARR=("${ARGS[@]}"); fi
  if (( MOVES > MAX )); then MAX=$MOVES; MAX_ARR=("${ARGS[@]}"); fi
done

printf -- "-------------------------------------------------------------\n"
AVG=$(( COUNT ? TOTAL / COUNT : 0 ))
printf "Total tests: %d\n" "$COUNT"
printf "Average moves: %d\n" "$AVG"
printf "Min moves: %d | %s\n" "$MIN" "$(join "${MIN_ARR[@]}")"
printf "Max moves: %d | %s\n" "$MAX" "$(join "${MAX_ARR[@]}")"
