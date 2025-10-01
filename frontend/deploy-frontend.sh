#!/bin/bash
# Retrieve the task definition from ECS
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_NAME_FE" --region "$REGION")

# Register a new task definition with an updated image
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$IMAGE_NAME_FE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
NEW_REVISION=$(aws ecs register-task-definition --region "$REGION" --cli-input-json "$NEW_TASK_DEFINITION")
echo $NEW_REVISION | jq '.taskDefinition.revision'

# Update the service with the new task definition
NEW_SERVICE=$(aws ecs update-service --region "$REGION" --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME_FE" --task-definition "$TASK_NAME_FE" --force-new-deployment)
echo $NEW_SERVICE