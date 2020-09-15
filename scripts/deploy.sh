#!/bin/bash -eu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"  # Figure out where the script is running
. "$SCRIPT_DIR"/lib-robust-bash.sh # load the robust bash library
PROJECT_ROOT="$SCRIPT_DIR"/.. # Figure out where the project directory is

# Ensure dependencies are present

require_binary aws
require_binary sam

# Deploy

OUTPUT_TEMPLATE_FILE="$PROJECT_ROOT/serverless-output.yml"
aws s3 mb "s3://$AWS_SAM_BUCKET_NAME" --region "$AWS_DEFAULT_REGION" || true
sam package --template-file template.yml --output-template-file "$OUTPUT_TEMPLATE_FILE"  --s3-bucket "$AWS_SAM_BUCKET_NAME"
sam deploy --region "$AWS_DEFAULT_REGION" --template-file "$OUTPUT_TEMPLATE_FILE" --stack-name "$AWS_SAM_STACK_NAME" --parameter-overrides GitHubClientIdParameter="$GITHUB_CLIENT_ID" GitHubClientSecretParameter="$GITHUB_CLIENT_SECRET" CognitoRedirectUriParameter="$COGNITO_REDIRECT_URI" StageNameParameter="$AWS_SAM_STAGE_NAME" JwtRs256KeyParameter="$JWT_RS256_KEY" JwtRs256PublicKeyParameter="$JWT_RS256_PUBLIC_KEY" --capabilities CAPABILITY_IAM
