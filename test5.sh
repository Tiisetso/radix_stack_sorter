#!/usr/bin/env bash
# test_5.sh — Exhaustively test push_swap on all permutations of 5 numbers.
# Usage:
#   chmod +x test_5.sh
#   ./test_5.sh                 # tests 1 2 3 4 5
#   ./test_5.sh 10 -3 7 0 2     # tests your custom 5 numbers

# ---- config / input ----
if (( $# == 0 )); then
  NUMS=(1 2 3 4 5)
else
  if (( $# != 5 )); then
    echo "Please pass exactly 5 distinct integers, or none to use: 1 2 3 4 5" >&2
    exit 1
  fi
  NUMS=("$@")
fi

# ---- helpers ----
join_array() {
  local IFS=" "
  echo "$*"
}

# permute <prefix_array...> -- <rest_array...>
permute() {
  local -a prefix rest
  local sep_seen=0
  for x in "$@"; do
    if [[ $sep_seen == 0 && $x == -- ]]; then
      sep_seen=1
      continue
    fi
    if (( sep_seen == 0 )); then
      prefix+=("$x")
    else
      rest+=("$x")
    fi
  done

  if (( ${#rest[@]} == 0 )); then
    # Run one test: prefix holds a complete permutation
    local OUT N
    # Pass args as separate words (safest)
    OUT=$(./push_swap "${prefix[@]}")
    # Count lines (number of moves)
    N=$(wc -l <<< "$OUT")
    # Print: moves | args
    printf "%6d | %s\n" "$N" "$(join_array "${prefix[@]}")"
    # Summary stats
    ((TOTAL += N))
    ((COUNT += 1))
    if (( N < MIN )); then MIN=$N; MIN_ARR=("${prefix[@]}"); fi
    if (( N > MAX )); then MAX=$N; MAX_ARR=("${prefix[@]}"); fi
    return
  fi

  local i x new_rest
  for (( i=0; i<${#rest[@]}; i++ )); do
    x=${rest[i]}
    # Build new_rest = rest without index i
    new_rest=("${rest[@]:0:i}" "${rest[@]:i+1}")
    permute "${prefix[@]}" "$x" -- "${new_rest[@]}"
  done
}

# ---- main ----
TOTAL=0
COUNT=0
MIN=9223372036854775807
MAX=-1
MIN_ARR=()
MAX_ARR=()

echo "Moves  | Args"
echo "-----------------------------"

permute -- "${NUMS[@]}"

echo "-----------------------------"
# avg with integer rounding
if (( COUNT > 0 )); then
  AVG=$(( TOTAL / COUNT ))
else
  AVG=0
fi
printf "Total cases: %d\n" "$COUNT"
printf "Average moves: %d\n" "$AVG"
printf "Min moves: %d  | %s\n" "$MIN" "$(join_array "${MIN_ARR[@]}")"
printf "Max moves: %d  | %s\n" "$MAX" "$(join_array "${MAX_ARR[@]}")"

