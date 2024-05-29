#!/usr/bin/env bash

set -ex

NUM_NODES=4

gantry run \
  --workspace ai2/OLMo-training \
  --task-name llamaish7-alibi-emb-init-fix-data-filter-wup0-fused-loss \
  --description "OLMo 7B stability experiments" \
  --priority high \
  --preemptible \
  --beaker-image petew/olmo-torch23-gantry \
  --cluster ai2/jupiter-cirrascale \
  --gpus 8 \
  --replicas "${NUM_NODES}" \
  --leader-selection \
  --host-networking \
  --budget ai2/oe-training \
  --propagate-failure \
  --synchronized-start-timeout "30m" \
  --no-nfs \
  --no-python \
  --env LOG_FILTER_TYPE=local_rank0_only \
  --env OMP_NUM_THREADS=8 \
  --env OLMO_TASK=model \
  --env R2_PROFILE=R2 \
  --env S3_PROFILE=S3 \
  --env WEKA_PROFILE=WEKA \
  --env-secret AWS_CONFIG=PETEW_AWS_CONFIG \
  --env-secret AWS_CREDENTIALS=PETEW_AWS_CREDENTIALS \
  --env-secret R2_ENDPOINT_URL=R2_ENDPOINT_URL \
  --env-secret WEKA_ENDPOINT_URL=WEKA_ENDPOINT_URL \
  --env-secret WANDB_API_KEY=PETEW_WANDB_API_KEY \
  --shared-memory 10GiB \
  --yes \
  --timeout=-1 \
  -- /bin/bash -c "scripts/beaker/epwalsh-stability/llamaish7.sh \$BEAKER_LEADER_REPLICA_HOSTNAME ${NUM_NODES} \$BEAKER_REPLICA_RANK"