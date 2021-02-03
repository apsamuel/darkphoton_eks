# Provisioning EKS Cluster for your website

## Prereqs

- AWS account, local authentication configured (populate `~/.aws/*`, or set the `AWS_*` env vars)
- create an IAM user (suggested to use a non-root account properly scoped with IAM perms) for admin tasks in AWS 
- install and configure awscli
- install terraform, kubectl, eksctl, helm
- install aws-iam-authenticator

## Install an EKS cluster in AWS account

1. Modify terraform variables appropriately and validate, plan, apply 
   - Be sure to first create and add any IAM users/roles you'd like to have access to the cluster to the appropriate tf variables.
2. Copy/Merge the newly created kubeconfig (created in repository root directory where terraforms main.tf is)
3. Ensure you can connect to the EKS cluster

    - ```bash
      kubectl --kubeconfig "kubeconfig_<clusterName>" get pods
      ```

4. Check to see if you have OIDC provider associated with cluster, if not, follow the steps to create and associate one

    - ```bash
      aws eks describe-cluster --name "<clusterName>" --query "cluster.identity.oidc.issuer" --output text
      ```

    - ```bash
      aws iam list-open-id-connect-providers
      ```

    - ```bash
      eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster="<clusterName>" --approve 
      ```

5. Create AWS LB Ingress controller IAM policy

    - ```bash
      curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.0/docs/install/iam_policy.json
      ```

    - ```bash
      aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam/aws_lb_controller_pol.json
      ```

6. Create a service account for ingress controller using policy

     - ```bash
       eksctl create iamserviceaccount \  
       --cluster=darkphoton1 \  
       --namespace=kube-system \
       --name=aws-load-balancer-controller \
       --attach-policy-arn=arn:aws:iam::<awsAccount>:policy/AWSLoadBalancerControllerIAMPolicy \
       --override-existing-serviceaccounts \
       --approve
       ```

7. Install certmanager and AWS LB Controller onto cluster 

    - ```bash
      curl -O https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml
      ```

    - ```bash
      curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.0/docs/install/v2_1_0_full.yaml
      ```

    - modify the v2_1_0 manifest, look for the value 'cluster-name' and add your <clusterName> as the value

    - ```bash
      kubectl apply --validate=false -f manifests/kube-system/aws-load-balancer-controller/2-aws-load-balancer-controller-v2_1_0_full.yaml
      ```

8. Optionally, deploy the 2048 application 

    - ```bash
      # fetch sample 2048 game manifest
      curl -o manifests/sample_full_2048/2048_full.yaml -L https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.0/docs/examples/2048/2048_full.yaml

      # apply manifest, creates ns, service, deployment, ingress, etc
      kubectl apply -f manifests/sample_full_2048/2048_full.yaml

      # verify lb controller and ingress health      
      kubectl logs -n kube-system   deployment.apps/aws-load-balancer-controller
      kubectl get ingress/ingress-2048 -n game-2048
      ```

9. Fin


### Additional Information

- Installing aws-iam-authenticator
  - <https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html>
- Managing users for EKS cluster
  - <https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html>
- Deploying a sample workload
  - <https://docs.aws.amazon.com/eks/latest/userguide/sample-deployment.html>
- Application load balancing EKS
  - <https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html>
- Load Balancer Controller
  - <https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html>
- Terraform module for EKS
  - <https://github.com/terraform-aws-modules/terraform-aws-eks>
- EKS RBAC
  - <https://kubernetes.io/docs/reference/access-authn-authz/rbac/>
    - NOTE: I may still need to enable this in my cluster..
