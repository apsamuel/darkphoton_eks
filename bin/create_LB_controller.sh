#!/usr/bin/env bash 

policy_arn="${1:-arn:aws:iam::192259153015:policy/AWSLoadBalancerControllerIAMPolicy}"
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=darkphoton1 --approve

eksctl create iamserviceaccount \
  --cluster=darkphoton1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=${policy_arn} \
  --override-existing-serviceaccounts \
  --approve
