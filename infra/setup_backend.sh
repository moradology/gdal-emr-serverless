#!/bin/bash

BUCKET_NAME="terraform-state-bucket"
DYNAMODB_TABLE="terraform-locks"

bucket_exists() {
    aws s3api head-bucket --bucket "$1" 2>/dev/null
}

table_exists() {
    aws dynamodb describe-table --table-name "$1" --region $AWS_DEFAULT_REGION 2>/dev/null
}

# Create S3 bucket if it doesn't exist
if ! bucket_exists $BUCKET_NAME; then
    echo "Creating S3 bucket: $BUCKET_NAME"
    aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
else
    echo "S3 bucket already exists: $BUCKET_NAME"
fi

# Create DynamoDB table if it doesn't exist
if ! table_exists $DYNAMODB_TABLE; then
    echo "Creating DynamoDB table: $DYNAMODB_TABLE"
    aws dynamodb create-table \
        --table-name $DYNAMODB_TABLE \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $AWS_DEFAULT_REGION
else
    echo "DynamoDB table already exists: $DYNAMODB_TABLE"
fi
