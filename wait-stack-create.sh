#!/bin/bash

wait_stack_create() {
    STACK_NAME=$1
    REGION=$2
    

    echo "Waiting for [$STACK_NAME] stack creation."

    aws cloudformation wait stack-create-complete \
    --region ${REGION}  \
    --stack-name ${STACK_NAME}
    status=$?

    if [[ ${status} -ne 0 ]] ; then
        # Waiter encountered a failure state.
        echo "Stack [${STACK_NAME}] creation failed. AWS error code is ${status}."

        exit ${status}
        else
        
       PRIVATE_IP_ADDRESS=`pcluster describe-cluster -n $1 --query headNode.privateIpAddress`
       PARAMETER_NAME="/RL/RG/StandardCatalog/ParallelCluster-test/${STACK_NAME}"
        aws ssm put-parameter --name "${PARAMETER_NAME}" --type "String" --value "${PRIVATE_IP_ADDRESS}"
        echo "private ip address of the head node is stored on ${PARAMETER_NAME}"
        echo "Private ip address is : ${PRIVATE_IP_ADDRESS}"
    fi
    return
}

