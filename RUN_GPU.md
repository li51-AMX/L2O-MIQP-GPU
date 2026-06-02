# GPU Run Instructions

This guide covers setup and training for both problems using the GPU-accelerated
MOREAU solver backend.

---

## Requirements

- NVIDIA GPU with CUDA driver >= 12.6
- Python 3.8+
- Gurobi license (for data generation only)

---

## 1. Environment Setup

```bash
# Create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate

# Install GPU dependencies (pulls CUDA 12.6 build of PyTorch)
pip install -r requirements-gpu.txt
```

Verify GPU is visible to PyTorch:

```bash
python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```

---

## 2. Energy Management Problem

```bash
cd energy/
```

### 2a. Generate data (skip if `data/data.npz` already exists)

```bash
python generate_data.py
```

### 2b. Train

Run all four training modes in sequence:

```bash
bash run.sh
```

Or run a single mode manually:

```bash
# Supervised learning (SL)
python train.py --w_sup 1.0 --w_obj 0.0 --w_slack 0.0 --w_con 0.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename energy_tank_sl

# Self-supervised learning (SSL)
python train.py --w_sup 0.0 --w_obj 1e-3 --w_slack 1.0 --w_con 1.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename energy_tank_ssl

# Hybrid learning variant 1 (HL-1)
python train.py --w_sup 1e2 --w_obj 0.0 --w_slack 1.0 --w_con 1.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename energy_tank_hl_1

# Hybrid learning variant 2 (HL-2)
python train.py --w_sup 1e1 --w_obj 0.0 --w_slack 0.0 --w_con 1.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename energy_tank_hl_2
```

Checkpoints are saved to `energy/checkpoints/`.

### 2c. Evaluate

```bash
python evaluate.py
```

---

## 3. Robot Navigation Problem

```bash
cd robot_nav/
```

### 3a. Generate data (skip if `data/single.p` already exists)

```bash
python generate_data.py
```

### 3b. Train

Run all four training modes in sequence:

```bash
bash run.sh
```

Or run a single mode manually:

```bash
# Supervised learning (SL)
python train.py --w_sup 1.0 --w_obj 0.0 --w_slack 0.0 --w_con 0.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename robot_nav_sl

# Self-supervised learning (SSL)
python train.py --w_sup 0.0 --w_obj 1e-5 --w_slack 1.0 --w_con 1.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename robot_nav_ssl

# Hybrid learning variant 1 (HL-1)
python train.py --w_sup 1e3 --w_obj 0.0 --w_slack 0.0 --w_con 1.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename robot_nav_hl_1

# Hybrid learning variant 2 (HL-2)
python train.py --w_sup 1e3 --w_obj 0.0 --w_slack 1.0 --w_con 1.0 \
    --TRAINING_EPOCHS 20 --save_stats --filename robot_nav_hl_2
```

Checkpoints are saved to `robot_nav/checkpoints/`.

### 3c. Evaluate

```bash
python evaluate.py
```

---

## 4. Loss Weight Reference

| Flag | Controls |
|------|----------|
| `--w_sup` | Supervised loss (requires labeled data) |
| `--w_obj` | Objective value loss |
| `--w_slack` | Slack variable penalty |
| `--w_con` | Constraint violation loss |

Set a weight to `0.0` to disable that loss term.

---

## 5. GPU Notes

- The CVXPY layer uses the **MOREAU solver** with `device="cuda"`. This is set
  automatically in `miqp.py` — no extra flags needed.
- Both `train.py` scripts auto-detect the GPU via
  `torch.device("cuda" if torch.cuda.is_available() else "cpu")`.
- The neural network and all tensors are moved to GPU during training.
- The CVXPY solver outputs are moved back to GPU after each solve.
- To fall back to CPU, comment out the GPU `CvxpyLayer` block in `miqp.py` and
  uncomment the CPU block (see comments in the file).
