#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH="/usr/local/lib/python3.13/dist-packages/nvidia/cuda_runtime/lib:/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}"

SCAN_SIZES=(1 2 3 255 256 257 1000 65536 1000003)
INPUTS=(ones random)
MODES=(scan find_repeats)

RENDER_SCENES=(rgb rgby rand10k rand100k rand1M micro2M biglittle littlebig pattern snowsingle snow bouncingballs hypnosis fireworks)
RENDER_SIZES=(256 512 768 1024)
SEEDS=(0 1 2)

echo "========================================"
echo "SCAN AND FIND_REPEATS CORRECTNESS SWEEP"
echo "========================================"

cd "$ROOT/scan"

for mode in "${MODES[@]}"; do
    for input in "${INPUTS[@]}"; do
        for n in "${SCAN_SIZES[@]}"; do
            echo "[SCAN] mode=$mode input=$input n=$n"
            ./cudaScan -m "$mode" -i "$input" -n "$n"
        done
    done
done

echo
echo "========================================"
echo "CUDA RENDERER CORRECTNESS SWEEP"
echo "========================================"

cd "$ROOT/render"

for scene in "${RENDER_SCENES[@]}"; do
    for size in "${RENDER_SIZES[@]}"; do
        for seed in "${SEEDS[@]}"; do
            echo "[RENDER] scene=$scene size=$size seed=$seed"
            ./render -c -s "$size" -S "$seed" "$scene"
        done
    done
done

echo
echo "========================================"
echo "ALL CORRECTNESS SWEEP CASES COMPLETED"
echo "========================================"
