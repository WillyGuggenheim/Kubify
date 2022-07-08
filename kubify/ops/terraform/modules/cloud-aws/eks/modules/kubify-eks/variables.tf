variable "cluster_name" {
  description = "should match the file name envs/[cluster_name].yaml"
  default     = "dev" # for envs/dev.yaml
}
variable "aws_region" {
  description = "should match the file name envs/[cluster_name].yaml"
  default     = "us-west-2"
}
variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}