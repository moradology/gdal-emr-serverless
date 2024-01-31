#!/bin/bash

show_help() {
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  apply           Apply Terraform changes"
  echo "  plan            Show Terraform execution plan"
  echo "  destroy         Destroy Terraform managed infrastructure"
  echo "  update_image    Build and push Docker image (not a terraform command)"
  echo "  *               Delegate to another Terraform command e.g. './tf workspace show'"
  echo ""
  echo "Remember to provide credentials: 'AWS_PROFILE=[profile] ./tf apply'"
  echo ""
}

# Check for arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

select_var_file() {
    workspace=$(terraform workspace show)
    var_file="terraform.${workspace}.tfvars"

    if [[ -f "$var_file" ]]; then
        echo "-var-file=${var_file}"
    else
        echo "No variable file found for workspace ${workspace}."
        exit 1
    fi
}

cd ./infra > /dev/null

if [[ ! -d ".terraform" ]]; then
    echo "Terraform not initialized. Running 'terraform init'..."
    terraform init
fi

case $1 in
    apply|plan|destroy)
        var_file_arg=$(select_var_file)
        terraform $1 $var_file_arg "${@:2}"
        ;;
    update_image)
        if ! command -v jq >/dev/null 2>&1; then
            echo "Error: 'jq' is not installed. Please install it to continue."
            exit 1
        fi
        workspace=$(terraform workspace show)
        state_file="./terraform.tfstate.d/${workspace}/terraform.tfstate"
        if [ ! -f "$state_file" ]; then
            echo "Error: Terraform state file for workspace '${workspace}' not found at ${state_file}. Make sure it exists."
            exit 1
        fi
        # Extract ECR Repository URL and EMR Release Label from workspace state
        REPO_URL=$(jq -r '.resources[] | select(.type == "aws_ecr_repository").instances[].attributes.repository_url' "$state_file")
        EMR_RELEASE_LABEL="emr-6.9.0"
        if [ -z "$REPO_URL" ]; then
            echo "Error: ECR Repository URL not found in terraform state for workspace '${workspace}'."
            exit 1
        fi
        ./manage_docker.sh push $REPO_URL $EMR_RELEASE_LABEL
        ;;
    shell)
        ./manage_docker.sh shell
        ;;
    *)
        # Directly passing other commands and arguments to Terraform
        terraform "$@"
        ;;
esac