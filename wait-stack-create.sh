#!/bin/bash

wait_stack_create() {
    STACK_NAME=$1
    REGION=$2
   

    echo "Waiting for [$STACK_NAME] stack creation."
    aws cloudformation wait stack-create-complete --region ${REGION} --stack-name ${STACK_NAME}
    status=$?

    if [[ ${status} -ne 0 ]] ; then
        # Waiter encountered a failure state.
        echo "Stack [${STACK_NAME}] creation failed. AWS error code is ${status}."
        trap '/opt/aws/bin/cfn-signal --exit-code 1 --resource EC2Instance --region ${AWS::Region} --stack ${AWS::StackName}' ERR
        exit 1
    else        
       INSTANCE_ID=`pcluster describe-cluster -n $1 --query headNode.instanceId`
       # PRIVATE_IP_ADDRESS=`pcluster describe-cluster -n $1 --query headNode.privateIpAddress`
       PARAMETER_NAME="/RL/RG/StandardCatalog/ParallelCluster-test/${STACK_NAME}"
       aws ssm put-parameter --name "${PARAMETER_NAME}" --type "String" --value "${INSTANCE_ID}"
       echo "Instance id of the head node is stored on ${PARAMETER_NAME}"
       echo "Instance id is : ${INSTANCE_ID}"
       /opt/aws/bin/cfn-signal --exit-code 0 --resource EC2Instance --region ${AWS::Region} --stack ${AWS::StackName}
    fi
    exit 0
}

