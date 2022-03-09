#!/bin/bash
echo "creating cluster-config.yaml file"
source /home/ubuntu/apc-ve/bin/activate
echo "Activated Virtual Environment"
scheduler=$1
Region=$2
headnodeinstancetype=$3
headnodesubnetId=$4
keyname=$5
computenodeinstancetype=$6
minvpc=$7
maxvpc=$8
computenodesubnetId=$9
if [ "$scheduler" == "slurm" ]; then
       echo "slurm.yaml exists"
       yq -i ".Region=\"$Region\"" slurm.yaml
       yq -i ".HeadNode.InstanceType=\"$headnodeinstancetype\"" slurm.yaml
       yq -i ".HeadNode.Networking.SubnetId=\"$headnodesubnetId\"" slurm.yaml
       yq -i ".HeadNode.Ssh.KeyName=\"$keyname\"" slurm.yaml
       yq -i ".Scheduling.SlurmQueues[0].ComputeResources[0].InstanceType=\"$computenodeinstancetype\"" slurm.yaml
       yq -i ".Scheduling.SlurmQueues[0].ComputeResources[0].MinCount=\"$minvpc\"" slurm.yaml
       yq -i ".Scheduling.SlurmQueues[0].ComputeResources[0].MaxCount=\"$maxvpc\"" slurm.yaml
       yq -i ".Scheduling.SlurmQueues[0].Networking.SubnetIds[0]=\"$computenodesubnetId\"" slurm.yaml
       echo "updated slurm.yaml"
else
       echo "batch.yaml exists"
       yq -i ".Region=\"$Region\"" batch.yaml
       yq -i ".HeadNode.InstanceType=\"$headnodeinstancetype\"" batch.yaml
       yq -i ".HeadNode.Networking.SubnetId=\"$headnodesubnetId\"" batch.yaml
       yq -i ".HeadNode.Ssh.KeyName=\"$keyname\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].InstanceTypes[0]=\"$computenodeinstancetype\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].MinvCpus=\"$minvpc\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].MaxvCpus=\"$maxvpc\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].Networking.SubnetIds[0]=\"$computenodesubnetId\"" batch.yaml
       echo "updated batch.yaml"
fi
