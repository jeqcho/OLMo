#!/usr/bin/env bash

set -ex

NUM_NODES=8

gantry run \
  --workspace ai2/shanea \
  --task-name lr-schedule-const-lr \
  --description "Const learning rate schedule experiment on OLMo 1B" \
  --priority high \
  --stop-preemptible \
  --beaker-image petew/olmo-torch2-gantry \
  --cluster ai2/pluto-cirrascale \
  --gpus 8 \
  --replicas "${NUM_NODES}" \
  --leader-selection \
  --host-networking \
  --budget ai2/oe-training \
  --nfs \
  --mount /net/nfs.cirrascale/allennlp/shanea/cache:/root/.cache \
  --env LOG_FILTER_TYPE=local_rank0_only \
  --env OMP_NUM_THREADS=8 \
  --env OLMO_TASK=model \
  --env-secret WANDB_API_KEY=WANDB_API_KEY \
  --env-secret AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID \
  --env-secret AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY \
  --env-secret R2_ACCESS_KEY_ID=R2_ACCESS_KEY_ID \
  --env-secret R2_SECRET_ACCESS_KEY=R2_SECRET_ACCESS_KEY \
  --env-secret R2_ENDPOINT_URL=R2_ENDPOINT_URL \
  --shared-memory 10GiB \
  --venv base \
  --yes \
  --timeout=-1 \
  -- /bin/bash -c "scripts/beaker/lr-scheduling.sh \$BEAKER_LEADER_REPLICA_HOSTNAME ${NUM_NODES}"