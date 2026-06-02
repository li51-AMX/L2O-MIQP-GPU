#!/bin/bash

run_timed() {
    local label=$1; shift
    echo "=== [$label] START: $(date '+%H:%M:%S') ==="
    local start=$SECONDS
    "$@"
    local elapsed=$((SECONDS - start))
    printf "=== [%s] DONE: %dm%ds ===\n\n" "$label" $((elapsed/60)) $((elapsed%60))
}

# ---- original runs (test.py, kept for reference) ----
# supervised learning
# python test.py \
#     --w_obj 0.0 \
#     --w_slack 0.0 \
#     --w_con 0.0 \
#     --w_sup 1.0 \
#     --save_stats \
#     --TRAINING_EPOCHS 10 \
#     --filename robot_nav_sl
# self-supervised learning
# python test.py \
#     --w_obj 1e-5 \
#     --w_slack 1.0 \
#     --w_con 1.0 \
#     --w_sup 0.0 \
#     --save_stats \
#     --filename robot_nav_ssl \
#     --TRAINING_EPOCHS 20 \
# # hybrid learning
# python test.py \
#     --w_obj 0.0 \
#     --w_slack 0.0 \
#     --w_con 1.0 \
#     --w_sup 1e3 \
#     --save_stats \
#     --filename robot_nav_hl_1 \
#     --TRAINING_EPOCHS 10
# python test.py \
#     --w_obj 0.0 \
#     --w_slack 1.0 \
#     --w_con 1.0 \
#     --w_sup 1e3 \
#     --save_stats \
#     --filename robot_nav_hl_2 \
#     --TRAINING_EPOCHS 20
# python train.py \
#     --w_obj 1e0 \
#     --w_slack 1.0 \
#     --w_con 1.0 \
#     --w_sup 1e4 \
#     --save_stats \
#     --filename robot_nav_hyl_3 \
#     --TRAINING_EPOCHS 20

# ---- active runs ----
# supervised learning
run_timed "SL" python train.py \
    --w_obj 0.0 \
    --w_slack 0.0 \
    --w_con 0.0 \
    --w_sup 1.0 \
    --save_stats \
    --filename robot_nav_sl \
    --TRAINING_EPOCHS 20

# self-supervised learning
run_timed "SSL" python train.py \
    --w_obj 1e-5 \
    --w_slack 1.0 \
    --w_con 1.0 \
    --w_sup 0.0 \
    --save_stats \
    --filename robot_nav_ssl \
    --TRAINING_EPOCHS 20

# hybrid learning
run_timed "HL-1" python train.py \
    --w_obj 0.0 \
    --w_slack 0.0 \
    --w_con 1.0 \
    --w_sup 1e3 \
    --save_stats \
    --filename robot_nav_hl_1 \
    --TRAINING_EPOCHS 20

run_timed "HL-2" python train.py \
    --w_obj 0.0 \
    --w_slack 1.0 \
    --w_con 1.0 \
    --w_sup 1e3 \
    --save_stats \
    --filename robot_nav_hl_2 \
    --TRAINING_EPOCHS 20

# run_timed "HYL-3" python train.py \
#     --w_obj 1e0 \
#     --w_slack 1.0 \
#     --w_con 1.0 \
#     --w_sup 1e4 \
#     --save_stats \
#     --filename robot_nav_hyl_3 \
#     --TRAINING_EPOCHS 20
