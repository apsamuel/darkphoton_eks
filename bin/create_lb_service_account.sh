#!/usr/bin/env bash 

cluster_name="${1:-darkphoton1}"
cluster_namespace="${2:-kube-system}"
account_name="${3:-aws-load-balancer-controller}"
policy_arn="${4:-arn:aws:iam::192259153015:policy/AWSLoadBalancerControllerIAMPolicy}"

eksctl create iamserviceaccount \
  --cluster=${cluster_name} \
  --namespace=${cluster_namespace} \
  --name=${account_name} \
  --attach-policy-arn=${policy_arn} \
  --override-existing-serviceaccounts \
  --approve
