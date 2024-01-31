#!/bin/bash

IMAGE_NAME="gdal-emr-serverless"

# Function to build Docker image
function build_docker_image() {
    echo "Building Docker image..."
    docker build -t "$1:latest" ../docker
    if [ $? -ne 0 ]; then
        echo "Docker build failed"
        exit 1
    fi
}

# Function to validate Docker image
function validate_docker_image() {
    echo "Validating Docker image..."
    if ! command -v amazon-emr-serverless-image &> /dev/null; then
      echo "Error: 'amazon-emr-serverless-image' command not found"
      exit 1
    fi
    amazon-emr-serverless-image \
        validate-image -r "$2" -t spark \
        -i "$1:latest"
    if [ $? -ne 0 ]; then
        echo "Image validation failed"
        exit 1
    fi
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "No argument supplied. Please specify 'test' or 'push'."
    exit 1
fi

# Test process
if [ "$1" = "test" ]; then
    build_docker_image "$IMAGE_NAME"
    validate_docker_image "$IMAGE_NAME" "emr-6.12.0"
    echo "Build and test completed successfully"

# Shell process
elif [ "$1" = "shell" ]; then
    build_docker_image "$IMAGE_NAME"
    docker run -it --entrypoint="/bin/bash" "${IMAGE_NAME}:latest"

# Push process
elif [ "$1" = "push" ]; then
    if [ $# -ne 3 ]; then
        echo "Insufficient arguments for 'push'. Usage: $0 push <REPO_URL> <EMR_RELEASE_LABEL>"
        exit 1
    fi
    REPO_URL=$2
    EMR_RELEASE_LABEL=$3

    build_docker_image "$IMAGE_NAME"
    validate_docker_image "$IMAGE_NAME" "$EMR_RELEASE_LABEL"

    echo "Tagging Docker image..."
    docker tag "${IMAGE_NAME}:latest" "${REPO_URL}:latest"
    if [ $? -ne 0 ]; then
        echo "Docker tag failed"
        exit 1
    fi

    echo "Logging into AWS ECR..."
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${REPO_URL%%/${REPO_NAME}*}"
    if [ $? -ne 0 ]; then
        echo "ECR login failed"
        exit 1
    fi

    echo "Pushing image to ECR..."
    docker push "${REPO_URL}:latest"
    if [ $? -ne 0 ]; then
        echo "Docker push failed"
        exit 1
    fi

    echo "Build and deploy completed successfully"

else
    echo "Invalid argument. Please specify 'test' or 'push'."
    exit 1
fi
