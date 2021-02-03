#!/usr/bin/env bash 

policy_file_path=${1:-iam/aws_lb_controller_pol.json}


debug="$(aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://${policy_file_path} 2>&1 ) "
if [ $? -ne 0 ]; then 
    echo "ERROR: ${debug}"
    exit -1
fi
