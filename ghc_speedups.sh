#!/bin/bash

# Create a temp file for stats output
STATFILE=$(mktemp -t ghcsweep.XXXXX)
trap 'rm "$STATFILE"' EXIT

# Default environment
OPTS="+RTS -t$STATFILE --machine-readable -RTS"
WRAPPER=""
MAXCORES=6
ITERS=3

# Custom i7-1250U host: we want to pin the process to the E-cores only
if (lscpu | grep "Model name:" | grep -cq "i7-1250U"); then
  WRAPPER="taskset -c 4-11"
  MAXCORES=8
fi

# Custom i5-9400F host: restrict max cores
if (lscpu | grep "Model name:" | grep -cq "i5-9400F"); then
  MAXCORES=6
fi

# Parse command line opts
while getopts bf: opt; do
    case $opt in
        b) MAXCORES=1 ;;
        f) BENCH=$OPTARG ;;
        ?) echo 'Usage: $0 [-b] -f <benchmark_binary>'
           echo 'The -b flag marks this as a baseline run (only on 1 core)'
           exit 1 ;;
    esac
done

# Helper to parse stat fields from GHC's output
getStat() {
    # First arg is destination variable name
    # Second arg is field name in GHC log
    val=`grep $2 $STATFILE | cut -f3 -d',' | tr -d '" )' `
    eval "$1=\$val"
}

# CSV header
echo "cores, total, mut, gc, productivity"

# Loop multiple times for each number of cores
for cores in $(seq 1 $MAXCORES); do
  for i in $(seq 1 $ITERS); do

    # Generate RTS args for number of cores
    if [ $MAXCORES -eq 1 ]; then
      NARG=""
    else
      NARG="+RTS -N$cores -RTS"
    fi

    # Run benchmark and collect stats
    $WRAPPER $BENCH $OPTS $NARG > /dev/null

    # Report stats
    getStat "t_wall" "total_wall_seconds"
    getStat "t_mut" "mut_wall_seconds"
    getStat "t_gc" "GC_wall_seconds"
    getStat "productivity" "productivity_wall_percent"
    echo "$cores, $t_wall, $t_mut, $t_gc, $productivity"
  done
done
