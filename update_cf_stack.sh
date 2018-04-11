#!/usr/bin/env bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
AWS_INFRA_CF_BUCKET_URL="https://s3.amazonaws.com/bootstrap-awss3cloudformationbucket-19qromfd235z9"
CF_BUCKET_URL="https://bootstrap-awss3cloudformationbucket-u7g8la3mrvxv"

STACK_NAME="bootstrap"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
# Handle message that shouldn't be an error, https://github.com/hashicorp/terraform/issues/5653
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="essentials"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=FhcrcVpnCidrip,ParameterValue=\"$FhcrcVpnCidrip\" \
ParameterKey=OperatorEmail,ParameterValue=\"$OperatorEmail\" \
ParameterKey=VpcPeeringRequesterAwsAccountId,ParameterValue=\"$AdmincentralAwsAccountId\""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="accounts"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nUpdating $STACK_NAME with template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=InitNewUserPassword,ParameterValue=\"$InitNewUserPassword\""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="vpc"
CF_TEMPLATE="vpc.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=PrivateSubnetZones,ParameterValue=\"us-east-1c,us-east-1d,us-east-1e\" \
ParameterKey=PublicSubnetZones,ParameterValue=\"us-east-1c,us-east-1d,us-east-1e\" \
ParameterKey=VpcName,ParameterValue="sagevpc" \
ParameterKey=VpcSubnetPrefix,ParameterValue="10.10""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peer-vpc-admincentral"
CF_TEMPLATE="peer-route-config.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=PeeringConnectionId,ParameterValue="pcx-3f28d957" \
ParameterKey=VpcPrivateRouteTable,ParameterValue="rtb-63ce7e1f" \
ParameterKey=VpcPublicRouteTable,ParameterValue="rtb-97ce7eeb" \
ParameterKey=VpnCidr,ParameterValue="10.1.0.0/16""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi
