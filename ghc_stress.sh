#!/bin/bash

# A wrapper script to run a benchmark N times with acces to a given number of cores.
# Useful for measuring average power usage.

# Create a temp file for stats output
STATFILE=$(mktemp -t ghcsweep.XXXXX)
trap 'rm "$STATFILE"' EXIT

# Default environment
OPTS="+RTS -t$STATFILE --machine-readable -RTS"
WRAPPER=""
MAXCORES=6
ITERS=25

# Custom i7-1250U host: we want to pin the process to the E-cores only
if (lscpu | grep "Model name:" | grep -cq "i7-1250U"); then
  #WRAPPER="taskset -c 4-11"
  #MAXCORES=8
  MAXCORES=12
fi

# Custom i5-9400F host: restrict max cores
if (lscpu | grep "Model name:" | grep -cq "i5-9400F"); then
  MAXCORES=6
fi

# Parse command line opts
while getopts bf: opt; do
    case $opt in
        f) BENCH=$OPTARG ;;
        ?) echo 'Usage: $0 -f <benchmark_binary>'
           exit 1 ;;
    esac
done

# Loop multiple times for each number of cores
for cores in $(seq $MAXCORES $MAXCORES); do

  NARG="+RTS -N$cores -RTS"

  # Run benchmark `i` times
  for i in $(seq 1 $ITERS); do
    $WRAPPER $BENCH $OPTS $NARG > /dev/null
  done
done
