#!/bin/bash
source ~/apc-ve/bin/activate
echo "Activated Virtual Environment"
echo "Retrieving Tags from Running Instance"
INSTANCE_ID=`wget -qO- http://instance-data/latest/meta-data/instance-id`
REGION=`wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed 's/.$//'`
aws ec2 describe-tags --region $REGION --filter "Name=resource-id,Values=$INSTANCE_ID" --query 'Tags[*].{Key:Key,Value:Value}' | jq -r '.[] | select( .Key as $a | ["cost_resource", "project_name","researcher_name"] | index($a) )' >> out.json
jq -s '.' out.json >> valid.json
echo "valid.json file is updated with Tags"
yq eval -P valid.json > valid.yaml
echo "Json file is converted to yaml"
sed -i '1 i\Tags:' valid.yaml
scheduler=$1
Region=$2
headnodeinstancetype=$3
headnodesubnetId=$4
keyname=$5
computenodeinstancetype=$6
minvpc=$7
maxvpc=$8
computenodesubnetId=$9
desiredvpc=${10}
spotbid=${11}
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
       sed -i 's/\"//g' slurm.yaml
       yq eval-all "select(fileIndex == 1) *+ select(fileIndex == 0)" valid.yaml slurm.yaml >> cluster-config-slurm.yaml
       echo "valid.yaml file and cluster-config.yaml file is merged into cluster-config-slurm.yaml"
       echo "Modified cluster-config-slurm.yaml with Tags"
       pcluster create-cluster --cluster-name test-cluster-$scheduler --cluster-configuration cluster-config-slurm.yaml
else
       echo "batch.yaml exists"
       yq -i ".Region=\"$Region\"" batch.yaml
       yq -i ".HeadNode.InstanceType=\"$headnodeinstancetype\"" batch.yaml
       yq -i ".HeadNode.Networking.SubnetId=\"$headnodesubnetId\"" batch.yaml
       yq -i ".HeadNode.Ssh.KeyName=\"$keyname\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].InstanceTypes[0]=\"$computenodeinstancetype\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].MinvCpus=\"$minvpc\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].MaxvCpus=\"$maxvpc\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].DesiredvCpus=\"$desiredvpc\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].ComputeResources[0].SpotBidPercentage=\"$spotbid\"" batch.yaml
       yq -i ".Scheduling.AwsBatchQueues[0].Networking.SubnetIds[0]=\"$computenodesubnetId\"" batch.yaml
       sed -i 's/\"//g' batch.yaml
       yq eval-all "select(fileIndex == 1) *+ select(fileIndex == 0)" valid.yaml batch.yaml >> cluster-config-batch.yaml
       echo "valid.yaml file and cluster-config.yaml file is merged into cluster-config-batch.yaml"
       echo "Modified cluster-config-batch.yaml with Tags"
       pcluster create-cluster --cluster-name test-cluster-$scheduler --cluster-configuration cluster-config-batch.yaml
       
fi
source ./wait-stack-create.sh
wait_stack_create test-cluster-$scheduler $Region

