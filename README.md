# Radix Stack Sorter

A fast, minimal implementation of the 42 "push_swap" project: compute a sequence of stack operations that sorts an input list of integers using two stacks and a restricted set of operations.

## Description
`push_swap` computes a series of operations (sa, sb, ss, pa, pb, ra, rb, rr, rra, rrb, rrr) that, when applied, sorts the provided integers. This project implements the [radix sort algorithm](https://en.wikipedia.org/wiki/Radix_sort). The goal is both correctness (resulting stack is sorted) and efficiency (few moves). 

## AI Declaration
ChatGPT was used to:
- assist in creation of the bash test scripts.
- assist in creation of README.md

## Requirements
- Linux / POSIX environment
- GCC or clang
- make

Optional test utilities in the repo:
- `checker_linux` — validates the produced moves
- `ps_check.sh` — randomized test harness using `checker_linux`
- `test5.sh` — exhaustive test for all permutations of 5 numbers

## Build
```bash
make        # builds ./push_swap
make clean  # remove object files
make fclean # remove binary and libft
make re     # recompile
```

## Usage
Run the program with a whitespace-separated list of integers:
```bash
./push_swap 3 2 1 0
```
The program prints moves to stdout (one per line). To verify correctness, pipe the moves into the checker:
```bash
./push_swap 3 1 2 | ./checker_linux 3 1 2
# Expected output: OK (if sorted)
```

Notes:
- Input must be valid 32-bit integers with no duplicates.
- The solver aims to minimize the move count; edge cases like small N use specialized strategies.

## Examples
```bash
# Simple sort
./push_swap 2 1 3

# Always verify with checker
./push_swap 5 3 2 4 1 | ./checker_linux 5 3 2 4 1
```

## Testing
- Randomised tests (ps_check): generates many random unique inputs, runs `push_swap`, and validates with `checker_linux`.

Usage:
```bash
# Make sure executables exist
make
chmod +x ps_check.sh
./ps_check.sh <numbers_per_test> <number_of_tests>
# Example: 100 numbers, 10 tests
./ps_check.sh 100 10
```

- Exhaustive 5-element test:
```bash
chmod +x test5.sh
./test5.sh            # tests permutations of 1 2 3 4 5
# or
./test5.sh 10 -3 7 0 2  # test user-specified 5 numbers
```

- You can also manually check a sequence of moves with `checker_linux`:
```bash
./push_swap 4 2 5 1 3 | ./checker_linux 4 2 5 1 3
```

## Project Structure 🔍
```
push_swap/
├── Makefile
├── push_swap          # binary (after build)
├── checker_linux      # validator
├── ps_check.sh        # random test script
├── test5.sh           # exhaustive 5-element tester
├── include/
│   └── push_swap.h
├── libft/             # helper library
├── src/
│   ├── a_op.c
│   ├── b_op.c
│   ├── bit.c
│   ├── parse.c
│   ├── push_swap.c
│   ├── radix.c
│   ├── sort.c
│   └── utils.c
└── obj/
```
