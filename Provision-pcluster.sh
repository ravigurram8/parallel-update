#!/bin/bash
echo "creating cluster-config.yaml file"
source /home/ubuntu/apc-ve/bin/activate
echo "Activated Virtual Environment"
scheduler=$1
Region=$2
if [ "$scheduler" == "slurm" ]; then
       echo "slurm.yaml exists"
       yq -i ".Region=\"$Region\"" slurm.yaml
       echo "updated Region in slurm.yaml"
else
       echo "batch.yaml exists"
       yq -i ".Region=\"$Region\"" batch.yaml
       echo "updated Region in batch.yaml"
fi
