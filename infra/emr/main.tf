# The EMR serverless application
resource "aws_emrserverless_application" "spark" {
  name                 = "${var.name}"
  type                 = "spark"
  release_label        = var.release_label

  image_configuration {
    image_uri          = var.image_uri
  }

  architecture         = var.architecture
  maximum_capacity {
    cpu                = var.max_cpu
    memory             = var.max_memory
  }

  network_configuration {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = var.emr_sg_ids
  }
}

# Permissions for application jobs to run using custom ECR
data "aws_iam_policy_document" "emr_serverless_ecr_policy" {
  statement {
    sid    = "EmrImageSupport_${var.ecr_repository_name}_${terraform.workspace}"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["emr-serverless.amazonaws.com"]
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [aws_emrserverless_application.spark.arn]
    }
  }
}

resource "aws_ecr_repository_policy" "emr_serverless_ecr_policy" {
  repository = var.ecr_repository_name
  policy     = data.aws_iam_policy_document.emr_serverless_ecr_policy.json
}

# Execution role (permissions for actual job runs)
data "template_file" "execution_role_policy" {
  template = file(var.execution_role_template)

  vars = {
    region = var.region
    account_id = var.account_id
  }
}

resource "aws_iam_policy" "emr_execution_policy" {
  name        = "EMRExecutionPolicy_${terraform.workspace}"
  description = "Custom IAM policy for EMR execution role"

  policy = "${data.template_file.execution_role_policy.rendered}"
}

# trust policy (allow principal to delegate iam role)
data "aws_iam_policy_document" "emr_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["emr-serverless.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "execution_role" {
  name = "EMRExecutionRole_${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.emr_trust_policy.json
}

resource "aws_iam_policy_attachment" "execution_role_policy_attachment" {
  name       = "EMRExecutionRolePolicyAttachment"
  roles      = [aws_iam_role.execution_role.name]
  policy_arn = aws_iam_policy.emr_execution_policy.arn
}