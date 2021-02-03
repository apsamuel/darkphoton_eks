variable "region" {
  default = "us-east-1"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::192259153015:user/darkphoton"
      username = "darkphoton"
      groups   = ["system:masters"]
    }
  ]
}

