#!/usr/bin/env bash
set -exuo pipefail
IFS=$'\n\t'

BEAKER_LEADER_REPLICA_HOSTNAME=$1
shift

NUM_NODES=$1
shift

# Warm HF cache
mkdir -p /root/.cache
pushd /root/.cache
curl "https://storage.googleapis.com/dirkgr-public/huggingface_cache_v3.tar.gz" | tar --keep-newer-files -xzf -
popd
export HF_DATASETS_OFFLINE=1

torchrun \
  --nnodes ${NUM_NODES}:${NUM_NODES} \
  --nproc-per-node 8 \
  --rdzv_id=101 \
  --rdzv_backend=c10d \
  --rdzv_endpoint=$BEAKER_LEADER_REPLICA_HOSTNAME:29400 \
  scripts/train.py \
    configs/lr-scheduling-s3.yaml \
      --run_name=lr-schedule-const-lr \
      --fsdp.sharding_strategy=SHARD_GRAD_OP \
      --load_path=/net/nfs.cirrascale/allennlp/shanea/checkpoints/lr-schedule-const-lr/step694500-unsharded \
      --wandb.name=lr-linear-decay-step694500-40000steps \
      --wandb.group=lr-linear-decay-step694500-40000steps \
      --scheduler.name=linear_with_warmup \
      --scheduler.t_warmup=694500 \
      --scheduler.alpha_f=0.0 \
      --max_duration=734500 \
      --save_overwrite