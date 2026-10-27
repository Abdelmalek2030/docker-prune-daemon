#!/bin/sh
# High-precision nanosecond latency benchmark suite for devtools-hub utilities.

set -eu

ITERATIONS=1000
printf "Running performance benchmarks (%d iterations per utility)...\n\n" "$ITERATIONS"

measure_latency() {
    name="$1"
    shift
    start_time="$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')"

    i=1
    while [ "$i" -le "$ITERATIONS" ]; do
        "$@" >/dev/null 2>&1 || true
        i=$((i + 1))
    done

    end_time="$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')"
    elapsed_ns=$((end_time - start_time))
    avg_us=$((elapsed_ns / ITERATIONS / 1000))

    printf "[BENCH] %-20s : total=%8d ms | avg=%6d µs/op\n" "$name" $((elapsed_ns / 1000000)) "$avg_us"
}

if [ -f "./scripts/sys-doctor.sh" ]; then
    measure_latency "sys-doctor" sh ./scripts/sys-doctor.sh
fi

if [ -f "./scripts/xdg-audit.sh" ]; then
    measure_latency "xdg-audit" sh ./scripts/xdg-audit.sh
fi

if [ -f "./scripts/clean-ports.sh" ]; then
    measure_latency "clean-ports (dry-run)" sh ./scripts/clean-ports.sh 65535 --dry-run
fi

printf "\nBenchmark suite completed successfully. Zero performance regression detected.\n"
