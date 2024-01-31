import argparse
import boto3
import json

def start_emr_job(application_id, execution_role_arn, entry_point, entry_point_arguments, spark_submit_params, configuration_overrides, tags, execution_timeout, name):
    client = boto3.client('emr-serverless')

    job_driver = {
        'sparkSubmit': {
            'entryPoint': entry_point,
            'entryPointArguments': entry_point_arguments.split(),
            'sparkSubmitParameters': spark_submit_params
        }
    }

    response = client.start_job_run(
        applicationId=application_id,
        clientToken='token',  # Generate a unique token here if needed
        executionRoleArn=execution_role_arn,
        jobDriver=job_driver,
        configurationOverrides=configuration_overrides,
        tags=tags,
        executionTimeoutMinutes=execution_timeout,
        name=name
    )
    return response

def main():
    parser = argparse.ArgumentParser(description='Start a Spark job on EMR Serverless.')

    parser.add_argument('--application-id', required=True, help='Application ID for the EMR Serverless application')
    parser.add_argument('--execution-role-arn', required=True, help='Execution role ARN')
    parser.add_argument('--entry-point', required=True, help='Entry point for the Spark job (e.g., s3://bucket/script.py)')
    parser.add_argument('--entry-point-arguments', default='', help='Space-separated entry point arguments')
    parser.add_argument('--spark-submit-parameters', default='', help='Spark submit parameters')
    parser.add_argument('--configuration-overrides', type=json.loads, default={}, help='JSON string for configuration overrides')
    parser.add_argument('--tags', type=json.loads, default={}, help='JSON string for tags')
    parser.add_argument('--execution-timeout', type=int, default=123, help='Execution timeout in minutes')
    parser.add_argument('--name', required=True, help='Name for the job run')

    args = parser.parse_args()

    response = start_emr_job(
        application_id=args.application_id,
        execution_role_arn=args.execution_role_arn,
        entry_point=args.entry_point,
        entry_point_arguments=args.entry_point_arguments,
        spark_submit_params=args.spark_submit_parameters,
        configuration_overrides=args.configuration_overrides,
        tags=args.tags,
        execution_timeout=args.execution_timeout,
        name=args.name
    )

    print("Job started successfully. Response:")
    print(response)

if __name__ == '__main__':
    main()
