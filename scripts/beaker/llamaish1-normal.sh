#!/usr/bin/env bash
set -exuo pipefail
IFS=$'\n\t'

BEAKER_LEADER_REPLICA_HOSTNAME=$1
shift

NUM_NODES=$1
shift

BEAKER_REPLICA_RANK=$1
shift

# Warm HF cache
mkdir -p /root/.cache
pushd /root/.cache
curl "https://storage.googleapis.com/dirkgr-public/huggingface_cache_v3.tar.gz" | tar --keep-newer-files -xzf -
popd
export HF_DATASETS_OFFLINE=1

export EXPERIMENT=llamaish1-dirk-baseline

torchrun \
  --nnodes ${NUM_NODES}:${NUM_NODES} \
  --nproc-per-node 8 \
  --rdzv_id=12347 \
  --rdzv_backend=static \
  --rdzv_endpoint=$BEAKER_LEADER_REPLICA_HOSTNAME:29400 \
  --node_rank=$BEAKER_REPLICA_RANK \
  --rdzv_conf="read_timeout=420" \
  scripts/train.py \
  configs/llamaish1-s3.yaml \
    --run_name=$EXPERIMENT \
    --wandb.name=$EXPERIMENT \
    --wandb.group=$EXPERIMENT \
    --model.flash_attention=true \
    --fsdp.wrapping_strategy=by_block_and_size \
    --fsdp.sharding_strategy=NO_SHARD \
    --gen1_gc_interval=null \
    --save_folder=runs/ \
    --activation_checkpointing=fine_grained \
    --fused_loss=true \
    --save_overwrite \
    --save_num_checkpoints_to_keep=3 \
    
