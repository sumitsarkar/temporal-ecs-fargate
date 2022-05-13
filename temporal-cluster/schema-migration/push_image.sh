#!/usr/bin/env bash

# Create repository if it doesn't exist
aws configure set region ap-south-1
aws ecr describe-repositories > repositories.json
jq ".repositories[] | select(.repositoryName==\"$SERVICE_NAME\").repositoryUri" repositories.json
export ECR_URL=$(jq ".repositories[] | select(.repositoryName==\"$SERVICE_NAME\").repositoryUri" repositories.json)
export ECR_URL=$(echo $ECR_URL | xargs)
if [ -z "$ECR_URL" ]; then aws ecr create-repository --repository-name $SERVICE_NAME; fi
aws ecr describe-repositories > repositories.json
jq ".repositories[] | select(.repositoryName==\"$SERVICE_NAME\").repositoryUri" repositories.json
export ECR_URL=$(jq ".repositories[] | select(.repositoryName==\"$SERVICE_NAME\").repositoryUri" repositories.json)
export ECR_URL=$(echo $ECR_URL | xargs)


echo ${ECR_URL} >> ecr_url

eval $(aws ecr get-login --no-include-email)

docker build --tag ${SERVICE_NAME}:${IMAGE_TAG} .
docker tag ${SERVICE_NAME}:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}
docker push ${ECR_URL}:${IMAGE_TAG}

echo ${ECR_URL}:${IMAGE_TAG} > ecr_image_url
