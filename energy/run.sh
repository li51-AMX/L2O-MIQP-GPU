#!/bin/bash

run_timed() {
    local label=$1; shift
    echo "=== [$label] START: $(date '+%H:%M:%S') ==="
    local start=$SECONDS
    "$@"
    local elapsed=$((SECONDS - start))
    printf "=== [%s] DONE: %dm%ds ===\n\n" "$label" $((elapsed/60)) $((elapsed%60))
}

# supervised learning
run_timed "SL" python train.py \
    --w_obj 0.0 \
    --w_slack 0.0 \
    --w_con 0.0 \
    --w_sup 1.0 \
    --save_stats \
    --filename energy_tank_sl \
    --TRAINING_EPOCHS 20

# self-supervised learning
run_timed "SSL" python train.py \
    --w_obj 1e-3 \
    --w_slack 1.0 \
    --w_con 1.0 \
    --w_sup 0.0 \
    --save_stats \
    --filename energy_tank_ssl \
    --TRAINING_EPOCHS 20

# hybrid learning
run_timed "HL-1" python train.py \
    --w_obj 0.0 \
    --w_slack 1.0 \
    --w_con 1.0 \
    --w_sup 1e2 \
    --save_stats \
    --filename energy_tank_hl_1 \
    --TRAINING_EPOCHS 20

run_timed "HL-2" python train.py \
    --w_obj 0.0 \
    --w_slack 0.0 \
    --w_con 1.0 \
    --w_sup 1e1 \
    --save_stats \
    --filename energy_tank_hl_2 \
    --TRAINING_EPOCHS 20
