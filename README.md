# GDAL on EMR-Serverless (`gdal-emr-serverless`)

## Overview

`gdal-emr-serverless` is a project focused on deploying and managing custom EMR-Serverless applications for geospatial processing with GDAL. It includes a Terraform management script (`tf`) and a Python CLI script for job submission to EMR-Serverless. The `tf` script streamlines Terraform operations across multiple environments, while the Python CLI script demonstrates one approach for the submission of Spark jobs to EMR-Serverless.

## Key Components

- **Terraform Script (`tf`)**: Manages infrastructure applications on EMR-Serverless using Terraform.
- **Workspace Management**: Utilizes Terraform workspaces for segregating environments like `dev`, `prod`, etc.
- **Docker Integration**: Handles building and pushing Docker images required for serverless applications that depend on GDAL.
- **EMR-Serverless Job Submission Script**: A Python CLI tool for submitting jobs to AWS EMR-Serverless.

## Prerequisites

- Terraform and [hashicorp aws provider >=4.62](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Docker (for image building and pushing)
- [Amazon EMR-Serverless Image CLI](https://github.com/awslabs/amazon-emr-serverless-image-cli) (for validation of images)
- [AWS CLI](https://aws.amazon.com/cli/) (configured for access to AWS services)
- Python with `boto3` (for the EMR-Serverless job submission script)
- Knowledge of Spark, AWS EMR-Serverless, and serverless concepts

## Usage

### Terraform Script (`tf`)

Execute Terraform commands within the project's infrastructure context:

```bash
./tf [terraform_command] [options]
```

Examples:

```bash
./tf plan
./tf apply
./tf destroy
```

If you run into permissions issues, don't forget to supply credentials. There are a lot of different mechanisms available here, so review the [docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html) as needed. Here's an example of using a pre-configured profile named "your-aws-profile":

```bash
AWS_PROFILE=your-aws-profile ./tf apply
```

### Managing Workspaces

Manage different deployment environments using workspaces. Automatically selects the appropriate variable file for the active workspace:

```bash
./tf workspace new [workspace_name]
./tf workspace select [workspace_name]
```

### Docker Image Management

Build and push Docker images as part of the infrastructure setup:

```bash
./tf update_image
```

### EMR-Serverless Job Submission Script

Submit jobs to EMR-Serverless using the Python CLI script:

```bash
python emr_job_cli.py \
  --application-id "app-id" \
  --execution-role-arn "arn:aws:iam::123456789012:role/MyRole" \
  --entry-point "s3://path/to/assembly.jar" \
  --entry-point-arguments "arg1 arg2 arg3" \
  --spark-submit-parameters "--executor-memory 1G --total-executor-cores 2" \
  --name "MySparkGDALJob"
```

Replace the placeholders with actual job details. `entryPointArguments` should be a space-separated list of arguments.

### Terraform Workspace Usage and Requirements

#### Overview

Terraform workspaces are extensively used to manage and isolate configurations for different environments in `gdal-emr-serverless`. 

### Important Notes

- **Avoid Default Workspace**: The project contains custom logic to prevent the use of Terraform's default workspace.
- **Workspace-Specific Configuration**: Each workspace requires a `terraform.[workspace].tfvars` file for environment-specific configurations.
- **Credentials and Secrets**: Handle AWS credentials and sensitive data securely, especially when using the job submission script.